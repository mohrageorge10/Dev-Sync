import 'package:devsync/features/profile/data/model/detected_skill.dart';

// Exception thrown when GitHub analysis fails.
class GithubException implements Exception {
  GithubException(this.message);

  final String message;
}

// Simulated GitHub analysis pipeline for skill detection.
class GithubService {
  static bool simulateFailure = false;

  static const stepTitles = [
    'Fetching repositories',
    'Detecting languages',
    'Reviewing activity',
    'Preparing your skills',
  ];

  static const stepHints = [
    '38 public repos found',
    'Dart, TypeScript, Python identified',
    'Analyzing commits & PR patterns...',
    'Drafting skill suggestions',
  ];

  // Emits each step index as it starts and resolves with the analysis result.
  Future<GithubAnalysis> analyze(
    void Function(int step) onStep, {
    String? username,
  }) async {
    for (var i = 0; i < stepTitles.length; i++) {
      onStep(i);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (simulateFailure && i == 2) {
        throw GithubException("Couldn't reach GitHub");
      }
    }

    final handle = (username != null && username.trim().isNotEmpty)
        ? username.trim()
        : 'devsync_user';

    return GithubAnalysis(
      username: handle,
      repos: 38,
      commits: 412,
      prsMerged: 18,
      languages: const {
        'Dart': 48,
        'Python': 32,
        'JavaScript': 15,
        'Shell': 5,
      },
      skills: [
        DetectedSkill(
          name: 'Flutter',
          confidence: 'High',
          evidence: '14 repositories • Active 4 days ago',
        ),
        DetectedSkill(
          name: 'Dart',
          confidence: 'High',
          evidence: '12 repositories • 240+ commits',
        ),
        DetectedSkill(
          name: 'REST APIs',
          confidence: 'Medium',
          evidence: '6 repositories • HTTP client integrations detected',
        ),
        DetectedSkill(
          name: 'State Management (BLoC)',
          confidence: 'Medium',
          evidence: '4 repositories • BLoC dependencies parsed',
        ),
      ],
    );
  }
}
