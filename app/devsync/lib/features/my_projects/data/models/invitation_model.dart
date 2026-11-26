// Status of an incoming project invitation.
enum InvitationStatus { pending, accepted, declined }

// Project invitation received by the current user.
class InvitationModel {
  InvitationModel({
    required this.id,
    required this.projectName,
    required this.ownerName,
    required this.ownerRole,
    required this.note,
    required this.role,
    required this.hoursPerWeek,
    required this.level,
    required this.responsibilities,
    required this.skills,
    this.projectId = '',
    this.status = InvitationStatus.pending,
  });

  final String id;
  final String projectId;
  final String projectName;
  final String ownerName;
  final String ownerRole;
  final String note;
  final String role;
  final String hoursPerWeek;
  final String level;
  final List<String> responsibilities;
  final List<String> skills;
  InvitationStatus status;
}
