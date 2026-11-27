import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Exception thrown when a GitHub REST API call fails.
class GithubException implements Exception {
  GithubException(this.message);

  final String message;

  @override
  String toString() => message;
}

// Real GitHub REST API v3 client for profile skill detection and PR status checks.
class GithubService {
  GithubService({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static const stepTitles = [
    'Fetching repositories',
    'Detecting languages',
    'Reviewing activity',
    'Preparing your skills',
  ];

  static const stepHints = [
    'Reading public repositories from GitHub...',
    'Calculating byte-level language ratios...',
    'Checking merged PRs & recent commits...',
    'Building verified skill suggestions...',
  ];

  static Dio _createDio() {
    final token = (dotenv.env['GITHUB_TOKEN'] ?? '').trim();
    return Dio(
      BaseOptions(
        baseUrl: 'https://api.github.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  // Extract a clean GitHub username from a handle or full profile URL.
  static String extractUsername(String raw) {
    var v = raw.trim();
    if (v.isEmpty) return '';
    v = v.replaceFirst(RegExp(r'^https?://(www\.)?github\.com/'), '');
    if (v.startsWith('@')) v = v.substring(1);
    final slashIdx = v.indexOf('/');
    if (slashIdx != -1) v = v.substring(0, slashIdx);
    return v.trim();
  }

  // Run the real 4-step GitHub REST API analysis pipeline for a public username.
  Future<GithubAnalysis> analyze(
    void Function(int step, {String? hint}) onStep, {
    required String username,
  }) async {
    final handle = extractUsername(username);
    if (handle.isEmpty) {
      throw GithubException('Please enter a valid GitHub username.');
    }

    try {
      // Step 0: Fetch user profile & public repositories.
      onStep(0, hint: 'Connecting to github.com/$handle...');
      final userRes = await _dio.get<Map<String, dynamic>>('/users/$handle');
      final userData = userRes.data ?? const <String, dynamic>{};
      final login = (userData['login'] ?? handle).toString();
      final publicReposCount = (userData['public_repos'] is num)
          ? (userData['public_repos'] as num).toInt()
          : 0;

      final reposRes = await _dio.get<List<dynamic>>(
        '/users/$login/repos',
        queryParameters: {'sort': 'updated', 'per_page': 100, 'type': 'owner'},
      );
      final repos = (reposRes.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      onStep(0, hint: '$publicReposCount public repos found');

      // Step 1: Fetch real byte-level language stats from top 8 non-fork repos.
      onStep(1, hint: 'Scanning language usage across repositories...');
      final ownRepos = repos.where((r) => r['fork'] != true).toList();
      final sampleRepos = ownRepos.take(8).toList();
      final langBytes = <String, int>{};
      final langRepoCount = <String, int>{};

      for (final r in ownRepos) {
        final primary = r['language']?.toString().trim();
        if (primary != null && primary.isNotEmpty) {
          langRepoCount[primary] = (langRepoCount[primary] ?? 0) + 1;
        }
      }

      await Future.wait(
        sampleRepos.map((r) async {
          final name = (r['name'] ?? '').toString();
          if (name.isEmpty) return;
          try {
            final res = await _dio.get<Map<String, dynamic>>(
              '/repos/$login/$name/languages',
            );
            final map = res.data;
            if (map != null) {
              map.forEach((lang, bytes) {
                if (bytes is num && bytes > 0) {
                  langBytes[lang] = (langBytes[lang] ?? 0) + bytes.toInt();
                }
              });
            }
          } catch (_) {}
        }),
      );

      // Fallback to primary repo languages if byte endpoint returned empty.
      if (langBytes.isEmpty) {
        langRepoCount.forEach((lang, count) {
          langBytes[lang] = count;
        });
      }

      final languagePercentages = _computePercentages(langBytes, maxItems: 5);
      final topLangHint = languagePercentages.keys.take(3).join(', ');
      onStep(
        1,
        hint: topLangHint.isNotEmpty
            ? '$topLangHint identified'
            : 'Repository languages scanned',
      );

      // Step 2: Fetch merged PR count & recent public push commits + total stars.
      onStep(2, hint: 'Checking merged PRs & recent commits...');
      final totalStars = repos.fold<int>(
        0,
        (sum, r) =>
            sum +
            ((r['stargazers_count'] is num)
                ? (r['stargazers_count'] as num).toInt()
                : 0),
      );

      final activityResults = await Future.wait([
        _fetchMergedPrCount(login),
        _fetchRecentCommitsCount(login),
      ]);
      final prsMerged = activityResults[0];
      final recentCommits = activityResults[1];

      onStep(2, hint: '$prsMerged merged PRs • $totalStars stars');

      // Step 3: Build verified DetectedSkill list from real languages, topics, and repos.
      onStep(3, hint: 'Drafting verified skill suggestions...');
      final skills = _inferSkills(
        languagePercentages: languagePercentages,
        langRepoCount: langRepoCount,
        repos: ownRepos,
      );

      return GithubAnalysis(
        username: login,
        repos: publicReposCount > 0 ? publicReposCount : repos.length,
        commits: recentCommits,
        prsMerged: prsMerged,
        stars: totalStars,
        languages: languagePercentages,
        skills: skills,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        throw GithubException('GitHub user "@$handle" was not found.');
      }
      if (status == 403 || status == 429) {
        throw GithubException(
          'GitHub API rate limit reached. Add GITHUB_TOKEN to .env or try again shortly.',
        );
      }
      if (status == 401) {
        throw GithubException(
          'Invalid GITHUB_TOKEN in .env. Check or regenerate your token.',
        );
      }
      throw GithubException(
        e.message ?? "Couldn't reach GitHub. Check your internet connection.",
      );
    } catch (e) {
      if (e is GithubException) rethrow;
      throw GithubException("Couldn't analyze GitHub profile.");
    }
  }

  // Fetch live Pull Request metadata from a GitHub PR URL (e.g. github.com/owner/repo/pull/42).
  Future<GithubPrInfo?> fetchPullRequestStatus(String prUrl) async {
    final match = RegExp(
      r'github\.com/([^/\s]+)/([^/\s]+)/pull/(\d+)',
      caseSensitive: false,
    ).firstMatch(prUrl.trim());
    if (match == null) return null;

    final owner = match.group(1)!;
    final repo = match.group(2)!;
    final number = match.group(3)!;

    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/repos/$owner/$repo/pulls/$number',
      );
      final d = res.data;
      if (d == null) return null;
      final user = d['user'] is Map ? d['user'] as Map : const {};
      return GithubPrInfo(
        number: (d['number'] is num)
            ? (d['number'] as num).toInt()
            : int.tryParse(number) ?? 0,
        title: (d['title'] ?? 'Pull Request #$number').toString(),
        state: (d['state'] ?? 'open').toString(),
        merged: d['merged'] == true || d['merged_at'] != null,
        author: (user['login'] ?? '').toString(),
        additions: (d['additions'] is num) ? (d['additions'] as num).toInt() : 0,
        deletions: (d['deletions'] is num) ? (d['deletions'] as num).toInt() : 0,
        htmlUrl: (d['html_url'] ?? prUrl).toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<int> _fetchMergedPrCount(String login) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/search/issues',
        queryParameters: {
          'q': 'author:$login type:pr is:merged',
          'per_page': 1,
        },
      );
      final total = res.data?['total_count'];
      return total is num ? total.toInt() : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchRecentCommitsCount(String login) async {
    try {
      final res = await _dio.get<List<dynamic>>(
        '/users/$login/events/public',
        queryParameters: {'per_page': 100},
      );
      var commits = 0;
      for (final raw in res.data ?? const []) {
        if (raw is! Map) continue;
        if (raw['type'] == 'PushEvent') {
          final payload = raw['payload'];
          if (payload is Map) {
            final size = payload['size'];
            if (size is num && size > 0) {
              commits += size.toInt();
            } else if (payload['commits'] is List) {
              commits += (payload['commits'] as List).length;
            } else {
              commits += 1;
            }
          }
        }
      }
      return commits;
    } catch (_) {
      return 0;
    }
  }

  Map<String, int> _computePercentages(
    Map<String, int> raw, {
    int maxItems = 5,
  }) {
    if (raw.isEmpty) return const {};
    final sorted = raw.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(maxItems).toList();
    final total = top.fold<int>(0, (s, e) => s + e.value);
    if (total <= 0) return const {};

    final result = <String, int>{};
    var sum = 0;
    for (var i = 0; i < top.length; i++) {
      final pct = i == top.length - 1
          ? (100 - sum).clamp(1, 100)
          : ((top[i].value * 100) / total).round().clamp(1, 100);
      result[top[i].key] = pct;
      sum += pct;
    }
    return result;
  }

  List<DetectedSkill> _inferSkills({
    required Map<String, int> languagePercentages,
    required Map<String, int> langRepoCount,
    required List<Map<String, dynamic>> repos,
  }) {
    final skills = <DetectedSkill>[];
    final seen = <String>{};

    void addSkill(String name, String confidence, String evidence) {
      final key = name.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) return;
      seen.add(key);
      skills.add(
        DetectedSkill(name: name, confidence: confidence, evidence: evidence),
      );
    }

    // 1. Add detected programming languages with real repo counts & percentages.
    for (final entry in languagePercentages.entries) {
      final repoCount = langRepoCount[entry.key] ?? 1;
      final confidence = entry.value >= 25 || repoCount >= 3 ? 'High' : 'Medium';
      addSkill(
        entry.key,
        confidence,
        '$repoCount ${repoCount == 1 ? 'repository' : 'repositories'} • ${entry.value}% of scanned code',
      );
    }

    // 2. Detect frameworks/tools from repository topics, names, and descriptions.
    const keywordMap = <String, String>{
      'flutter': 'Flutter',
      'firebase': 'Firebase',
      'react': 'React',
      'nextjs': 'Next.js',
      'next-js': 'Next.js',
      'nodejs': 'Node.js',
      'node': 'Node.js',
      'express': 'Express.js',
      'django': 'Django',
      'fastapi': 'FastAPI',
      'spring': 'Spring Boot',
      'docker': 'Docker',
      'kubernetes': 'Kubernetes',
      'mongodb': 'MongoDB',
      'postgres': 'PostgreSQL',
      'postgresql': 'PostgreSQL',
      'graphql': 'GraphQL',
      'tailwind': 'Tailwind CSS',
      'bloc': 'BLoC',
      'pytorch': 'PyTorch',
      'tensorflow': 'TensorFlow',
      'machine-learning': 'Machine Learning',
      'rest-api': 'REST APIs',
      'android': 'Android',
      'ios': 'iOS',
      'unity': 'Unity',
      'figma': 'Figma',
    };

    final toolHits = <String, int>{};
    for (final r in repos) {
      final haystack = <String>[
        (r['name'] ?? '').toString().toLowerCase(),
        (r['description'] ?? '').toString().toLowerCase(),
        if (r['topics'] is Iterable)
          for (final t in r['topics'] as Iterable) t.toString().toLowerCase(),
      ].join(' ');

      keywordMap.forEach((keyword, label) {
        if (haystack.contains(keyword)) {
          toolHits[label] = (toolHits[label] ?? 0) + 1;
        }
      });
    }

    // If Dart is strongly present, infer Flutter when Dart repos exist.
    if (languagePercentages.containsKey('Dart') &&
        !toolHits.containsKey('Flutter')) {
      toolHits['Flutter'] = langRepoCount['Dart'] ?? 1;
    }

    final sortedTools = toolHits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedTools.take(6)) {
      final confidence = entry.value >= 2 ? 'High' : 'Medium';
      addSkill(
        entry.key,
        confidence,
        'Detected across ${entry.value} ${entry.value == 1 ? 'repository' : 'repositories'}',
      );
    }

    return skills;
  }
}
