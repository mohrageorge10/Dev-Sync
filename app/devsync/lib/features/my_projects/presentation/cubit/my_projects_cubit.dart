import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart'
    as discover;
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/applicant_model.dart';
import '../../data/models/developer_model.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repo/my_projects_repo.dart';

part 'my_projects_state.dart';

// Cubit managing ongoing/previous projects, invitations, applicants, and repo rules.
class MyProjectsCubit extends Cubit<MyProjectsState> {
  MyProjectsCubit(this.repo) : super(MyProjectsInitial());

  final MyProjectsRepo repo;
  List<DeveloperModel> developers = [];

  TeamsController? get _teamsController =>
      ServiceLocator.isRegistered<TeamsController>()
      ? ServiceLocator.get<TeamsController>()
      : null;

  // Resolve full developer profile for an applicant.
  Future<discover.DeveloperModel> resolveApplicantProfile(
    ApplicantModel applicant,
  ) => repo.resolveApplicantProfile(applicant);

  // Sync changes coming from My Teams (e.g. repo URL or member removal).
  void syncFromTeam({
    required String projectId,
    String? repoUrl,
    int? membersCountDelta,
  }) {
    final s = state;
    if (s is! MyProjectsLoaded) return;
    final project = s.projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null) return;

    var changed = false;
    if (repoUrl != null && repoUrl.trim() != project.repoUrl) {
      project.repoUrl = repoUrl.trim();
      project.cloneUrl = ProjectModel.deriveCloneUrl(repoUrl);
      changed = true;
    }
    if (membersCountDelta != null && membersCountDelta != 0) {
      project.membersCount = (project.membersCount + membersCountDelta).clamp(
        1,
        project.totalSeats,
      );
      changed = true;
    }
    if (changed) emit(_copy(s));
  }

  // Load projects, invitations, applicants, and suggested developers.
  Future<void> loadData() async {
    emit(MyProjectsLoading());
    try {
      final projects = await repo.getProjects();
      final ownedIds =
          projects.where((p) => p.isOwner).map((p) => p.id).toList();
      final results = await Future.wait([
        repo.getInvitations(),
        repo.getApplicants(ownedProjectIds: ownedIds),
        repo.getDevelopers(),
      ]);
      if (isClosed) return;
      developers = results[2] as List<DeveloperModel>;
      emit(
        MyProjectsLoaded(
          projects: projects,
          invitations: results[0] as List<InvitationModel>,
          applicants: results[1] as List<ApplicantModel>,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(MyProjectsError('Something went wrong, please try again'));
      }
    }
  }

  // Update editable project details (title, description, seats, tags, open roles).
  Future<void> updateProjectDetails(
    String projectId, {
    required String name,
    required String description,
    required int totalSeats,
    required List<String> tags,
    required List<String> openRoles,
  }) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null || !project.isOwner) return;

    project.name = name.trim();
    project.description = description.trim();
    project.totalSeats = totalSeats.clamp(project.membersCount, 20);
    project.tags = List<String>.from(tags);
    project.openRoles = List<String>.from(openRoles);

    emit(_copy(s, message: 'Project updated'));
    _teamsController?.syncProjectMetadata(
      teamId: project.id,
      name: project.name,
      totalSeats: project.totalSeats,
    );
    await repo.updateProjectDetails(project);
  }

  // Update repository URL, clone URL, base branch, and Git workflow rules.
  Future<void> updateRepoAndRules(
    String projectId, {
    required String repoUrl,
    required String cloneUrl,
    required String defaultBranch,
    required GitWorkflowRules gitRules,
  }) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null || !project.isOwner) return;

    project.repoUrl = repoUrl.trim();
    project.cloneUrl = cloneUrl.trim().isEmpty
        ? ProjectModel.deriveCloneUrl(repoUrl)
        : cloneUrl.trim();
    project.defaultBranch = defaultBranch.trim().isEmpty
        ? 'develop'
        : defaultBranch.trim();
    project.gitRules = gitRules;

    emit(_copy(s, message: 'Repository & Git rules updated'));
    _teamsController?.syncProjectMetadata(
      teamId: project.id,
      repoUrl: project.repoUrl,
    );
    await repo.updateRepoAndRules(project);
  }

  // Accept or decline an incoming project invitation.
  Future<void> respondToInvitation(String id, bool accept) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final invitation = s.invitations.where((i) => i.id == id).firstOrNull;
    if (invitation == null) return;
    invitation.status =
        accept ? InvitationStatus.accepted : InvitationStatus.declined;

    if (accept) {
      s.projects.add(
        ProjectModel(
          id: invitation.projectId.isNotEmpty
              ? invitation.projectId
              : 'joined_$id',
          name: invitation.projectName,
          description: 'Role: ${invitation.role}',
          statusText: 'Active',
          isOwner: false,
          membersCount: 1,
          totalSeats: 4,
          tags: invitation.skills,
          openRoles: [],
        ),
      );
    }

    emit(
      _copy(
        s,
        message: accept ? 'Invitation accepted' : 'Invitation declined',
      ),
    );
    await repo.respondToInvitation(invitation, accept);
    if (accept) {
      await _teamsController?.loadData(force: true);
    }
  }

  // Accept or decline an applicant's join request and sync member to My Teams.
  Future<void> respondToApplicant(String id, bool accept) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final applicant = s.applicants.where((a) => a.id == id).firstOrNull;
    if (applicant == null) return;
    applicant.status =
        accept ? ApplicantStatus.accepted : ApplicantStatus.declined;

    int? updatedCount;
    if (accept && applicant.projectId.isNotEmpty) {
      final project =
          s.projects.where((p) => p.id == applicant.projectId).firstOrNull;
      if (project != null) {
        if (project.membersCount < project.totalSeats) {
          project.membersCount += 1;
        } else {
          project.membersCount += 1;
          project.totalSeats = project.membersCount;
        }
        updatedCount = project.membersCount;
        final roleIdx = project.openRoles.indexWhere(
          (r) =>
              r.trim().toLowerCase() == applicant.position.trim().toLowerCase(),
        );
        if (roleIdx != -1) {
          project.openRoles = List<String>.from(project.openRoles)
            ..removeAt(roleIdx);
        }
      }
      final memberUid = applicant.applicantUid.isNotEmpty
          ? applicant.applicantUid
          : applicant.id;
      final handle = applicant.username.isNotEmpty
          ? (applicant.username.startsWith('@')
              ? applicant.username
              : '@${applicant.username}')
          : '@${applicant.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';
      _teamsController?.syncMemberAdded(
        teamId: applicant.projectId,
        teamName: project?.name,
        member: Member(
          id: memberUid,
          name: applicant.name,
          handle: handle,
          role: applicant.position,
          teamRole: TeamRole.member,
        ),
      );
    }

    emit(
      _copy(
        s,
        message: accept
            ? '${applicant.name} added to team'
            : 'Applicant declined',
      ),
    );
    await repo.respondToApplicant(
      applicant,
      accept,
      updatedMembersCount: updatedCount,
    );
  }

  // Send a project invitation to a developer and persist it.
  Future<void> sendInvitation({
    required ProjectModel project,
    required DeveloperModel developer,
    required String role,
    required String message,
  }) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;
    emit(
      _copy(
        s,
        sentInvitations: s.sentInvitations + 1,
        message: 'Invitation sent to ${developer.name}',
      ),
    );
    await repo.sendInvitation(
      project: project,
      developer: developer,
      role: role,
      message: message,
    );
  }

  // Publish a saved draft project to Ongoing.
  Future<void> publishDraft(String id) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == id).firstOrNull;
    if (project == null || !project.isOwner) return;
    project.type = ProjectType.ongoing;
    project.statusText = 'Active • Open';

    emit(_copy(s, message: '"${project.name}" published to Ongoing'));
    await repo.publishDraft(id);
  }

  // Delete a saved draft project.
  Future<void> deleteDraft(String id) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == id).firstOrNull;
    if (project == null || !project.isOwner) return;
    s.projects.removeWhere((p) => p.id == id);

    emit(_copy(s, message: 'Draft deleted'));
    await repo.deleteProject(id);
  }

  // Archive an active owned project.
  Future<void> archiveProject(String id) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == id).firstOrNull;
    if (project == null) return;
    project.type = ProjectType.previous;
    project.statusText = 'Archived';

    emit(_copy(s, message: 'Project archived'));
    await repo.setProjectArchived(id, true);
  }

  // Restore an archived owned project back to Ongoing.
  Future<void> restoreProject(String id) async {
    final s = state;
    if (s is! MyProjectsLoaded) return;

    final project = s.projects.where((p) => p.id == id).firstOrNull;
    if (project == null || !project.isOwner) return;
    project.type = ProjectType.ongoing;
    project.statusText = 'Active • Open';

    emit(_copy(s, message: 'Project restored to Ongoing'));
    await repo.setProjectArchived(id, false);
  }

  // Reset state when signing out.
  void reset() {
    developers = [];
    emit(MyProjectsInitial());
  }

  MyProjectsLoaded _copy(
    MyProjectsLoaded s, {
    int? sentInvitations,
    String? message,
  }) {
    return MyProjectsLoaded(
      projects: List<ProjectModel>.from(s.projects),
      invitations: List<InvitationModel>.from(s.invitations),
      applicants: List<ApplicantModel>.from(s.applicants),
      sentInvitations: sentInvitations ?? s.sentInvitations,
      message: message,
    );
  }
}
