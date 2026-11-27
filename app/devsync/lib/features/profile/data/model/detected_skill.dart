// Review status for a GitHub-detected skill suggestion.
enum SkillStatus { suggested, added, dismissed }

// Skill inferred from GitHub repository and commit activity.
class DetectedSkill {
  DetectedSkill({
    required this.name,
    required this.confidence,
    required this.evidence,
    this.meta,
    this.status = SkillStatus.suggested,
  });

  final String name;
  final String confidence;
  final String evidence;
  final String? meta;
  SkillStatus status;
}

// Live GitHub Pull Request status fetched from GitHub REST API.
class GithubPrInfo {
  const GithubPrInfo({
    required this.number,
    required this.title,
    required this.state,
    required this.merged,
    required this.author,
    this.additions = 0,
    this.deletions = 0,
    required this.htmlUrl,
  });

  final int number;
  final String title;
  final String state;
  final bool merged;
  final String author;
  final int additions;
  final int deletions;
  final String htmlUrl;

  String get displayStatus => merged
      ? 'Merged'
      : state.toLowerCase() == 'open'
      ? 'Open'
      : 'Closed';
}

// Aggregated real public GitHub activity and detected skills.
class GithubAnalysis {
  const GithubAnalysis({
    required this.username,
    required this.repos,
    required this.commits,
    required this.prsMerged,
    this.stars = 0,
    required this.languages,
    required this.skills,
  });

  final String username;
  final int repos;
  final int commits;
  final int prsMerged;
  final int stars;
  final Map<String, int> languages;
  final List<DetectedSkill> skills;

  Map<String, dynamic> toFirestoreMap() => {
    'username': username,
    'repos': repos,
    'commits': commits,
    'prsMerged': prsMerged,
    'stars': stars,
    'languages': languages,
  };

  factory GithubAnalysis.fromFirestoreMap(Map<String, dynamic> map) {
    final rawLangs = map['languages'];
    final langs = <String, int>{};
    if (rawLangs is Map) {
      rawLangs.forEach((k, v) {
        if (v is num) langs[k.toString()] = v.toInt();
      });
    }
    return GithubAnalysis(
      username: (map['username'] ?? '').toString(),
      repos: (map['repos'] is num) ? (map['repos'] as num).toInt() : 0,
      commits: (map['commits'] is num) ? (map['commits'] as num).toInt() : 0,
      prsMerged:
          (map['prsMerged'] is num) ? (map['prsMerged'] as num).toInt() : 0,
      stars: (map['stars'] is num) ? (map['stars'] as num).toInt() : 0,
      languages: langs,
      skills: const [],
    );
  }
}
