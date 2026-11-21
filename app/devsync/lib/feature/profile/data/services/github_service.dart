import '../models/detected_skill.dart';

class GithubException implements Exception {
  final String message;
  GithubException(this.message);
}

/// Mock service. Replace the bodies with real OAuth + GitHub REST/GraphQL calls.
class GithubService {
  /// Flip to true to preview the "Connection Interrupted" fallback.
  static bool simulateFailure = false;

  static const stepTitles = ['Fetching repositories', 'Detecting languages', 'Reviewing activity', 'Preparing your skills'];
  static const stepHints = [
    '38 public repos found',
    'Dart, TypeScript, Python identified',
    'Analyzing commits & PR patterns...',
    'Drafting skill suggestions',
  ];

  /// Emits the index of each step as it STARTS; completes with the result.
  Future<GithubAnalysis> analyze(void Function(int step) onStep) async {
    for (var i = 0; i < stepTitles.length; i++) {
      onStep(i);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (simulateFailure && i == 2) throw GithubException('Couldn\'t reach GitHub');
    }
    return GithubAnalysis(
      username: 'alexmorgan',
      repos: 38,
      commits: 412,
      prsMerged: 18,
      languages: const {'Dart': 48, 'Python': 32, 'JavaScript': 15, 'Shell': 5},
      skills: [
        DetectedSkill(name: 'Flutter', confidence: 'High', evidence: '14 repositories • Active 4 days ago'),
        DetectedSkill(name: 'Dart', confidence: 'High', evidence: '12 repositories • 240+ commits'),
        DetectedSkill(name: 'REST APIs', confidence: 'Medium', evidence: '6 repositories • HTTP client integrations detected'),
        DetectedSkill(name: 'State Management (Riverpod)', confidence: 'Medium', evidence: '4 repositories • Riverpod dependencies parsed'),
      ],
    );
  }
}
