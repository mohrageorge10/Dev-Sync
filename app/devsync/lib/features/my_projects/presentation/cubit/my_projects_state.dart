part of 'my_projects_cubit.dart';

// Base state for My Projects feature.
abstract class MyProjectsState {}

class MyProjectsInitial extends MyProjectsState {}

class MyProjectsLoading extends MyProjectsState {}

// Loaded state holding projects, invitations, applicants, outgoing applications, and feedback message.
class MyProjectsLoaded extends MyProjectsState {
  MyProjectsLoaded({
    required this.projects,
    required this.invitations,
    required this.applicants,
    this.myApplications = const [],
    this.sentInvitations = 0,
    this.message,
  });

  final List<ProjectModel> projects;
  final List<InvitationModel> invitations;
  final List<ApplicantModel> applicants;
  final List<MyApplicationModel> myApplications;
  final int sentInvitations;
  final String? message;

  List<ProjectModel> get ongoing =>
      projects.where((p) => p.type == ProjectType.ongoing).toList();

  List<ProjectModel> get drafted =>
      projects.where((p) => p.type == ProjectType.draft).toList();

  List<ProjectModel> get previous =>
      projects.where((p) => p.type == ProjectType.previous).toList();

  List<InvitationModel> get pendingInvitations => invitations
      .where((i) => i.status == InvitationStatus.pending)
      .toList();

  List<ApplicantModel> get pendingApplicants =>
      applicants.where((a) => a.status == ApplicantStatus.pending).toList();

  List<ApplicantModel> pendingApplicantsFor(String projectId) =>
      pendingApplicants
          .where((a) => a.projectId.isEmpty || a.projectId == projectId)
          .toList();
}

class MyProjectsError extends MyProjectsState {
  MyProjectsError(this.message);

  final String message;
}
