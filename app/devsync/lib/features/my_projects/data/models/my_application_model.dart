// Status of an outgoing join request submitted by the current user.
enum ApplicationStatus { pending, accepted, declined }

// Represents a project the current user applied to join.
class MyApplicationModel {
  const MyApplicationModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.track,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String projectId;
  final String projectTitle;
  final String track;
  final ApplicationStatus status;
  final DateTime? createdAt;
}
