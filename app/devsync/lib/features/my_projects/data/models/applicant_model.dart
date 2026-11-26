// Status of an incoming join request from an applicant.
enum ApplicantStatus { pending, accepted, declined }

// Applicant model for incoming project join requests.
class ApplicantModel {
  ApplicantModel({
    required this.id,
    required this.name,
    required this.title,
    required this.location,
    required this.matchPercent,
    required this.position,
    required this.coverNote,
    required this.skills,
    this.projectId = '',
    this.applicantUid = '',
    this.level = 'Intermediate',
    this.username = '',
    this.photoUrl,
    this.status = ApplicantStatus.pending,
  });

  final String id;
  final String projectId;
  final String applicantUid;
  final String name;
  final String title;
  final String location;
  final String level;
  final String username;
  final String? photoUrl;
  final int matchPercent;
  final String position;
  final String coverNote;
  final List<String> skills;
  ApplicantStatus status;
}
