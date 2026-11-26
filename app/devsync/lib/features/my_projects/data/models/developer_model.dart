// Suggested developer candidate available to invite.
class DeveloperModel {
  DeveloperModel({
    required this.id,
    required this.name,
    required this.title,
    required this.fitPercent,
    required this.skills,
  });

  final String id;
  final String name;
  final String title;
  final int fitPercent;
  final List<String> skills;
}
