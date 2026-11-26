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

// Aggregated public GitHub activity and detected skills.
class GithubAnalysis {
  const GithubAnalysis({
    required this.username,
    required this.repos,
    required this.commits,
    required this.prsMerged,
    required this.languages,
    required this.skills,
  });

  final String username;
  final int repos;
  final int commits;
  final int prsMerged;
  final Map<String, int> languages;
  final List<DetectedSkill> skills;
}
