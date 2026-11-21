enum SkillStatus { suggested, added, dismissed }

class DetectedSkill {
  final String name;
  final String confidence; // High | Medium
  final String evidence;
  final String? meta;
  SkillStatus status;
  DetectedSkill({required this.name, required this.confidence, required this.evidence, this.meta, this.status = SkillStatus.suggested});
}

class GithubAnalysis {
  final String username;
  final int repos, commits, prsMerged;
  final Map<String, int> languages; // name -> %
  final List<DetectedSkill> skills;
  const GithubAnalysis({
    required this.username,
    required this.repos,
    required this.commits,
    required this.prsMerged,
    required this.languages,
    required this.skills,
  });
}
