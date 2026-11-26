import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/data/repositories/teams_repository.dart';
import 'package:flutter/material.dart';

// Central state controller for My Teams, Task Board, Role-Based Permissions, and Firestore sync.
class TeamsController extends ChangeNotifier {
  TeamsController({TeamsRepository? repository}) : _repository = repository {
    _seedFallback();
  }

  final TeamsRepository? _repository;

  bool isLoading = false;
  bool _hasLoaded = false;

  late Member me;
  final List<Team> _teams = [];
  final List<TaskItem> _tasks = [];
  int _nextNumber = 104;

  List<Team> get teams => List.unmodifiable(_teams);

  // Safe lookups returning null if a team or task was deleted/left.
  Team? findTeamById(String id) => _teams.where((t) => t.id == id).firstOrNull;

  TaskItem? findTaskById(String id) =>
      _tasks.where((t) => t.id == id).firstOrNull;

  List<TaskItem> tasksOf(String teamId) =>
      _tasks.where((t) => t.teamId == teamId).toList();

  // Resolve the current user's TeamRole in a given team.
  TeamRole roleOf(String teamId) {
    final team = findTeamById(teamId);
    if (team == null) return TeamRole.member;
    if (team.isOwner || (team.ownerId.isNotEmpty && team.ownerId == me.id)) {
      return TeamRole.owner;
    }
    final member = team.members.where((m) => m.id == me.id).firstOrNull;
    return member?.effectiveRole ?? TeamRole.member;
  }

  // Resolve effective permissions for the current user in a given team.
  RolePermissions permissionsFor(String teamId) {
    final team = findTeamById(teamId);
    if (team == null) return RolePermissions.defaultMember;
    return team.settings.permissionsFor(roleOf(teamId));
  }

  bool isOwnerOf(String teamId) => roleOf(teamId) == TeamRole.owner;
  bool canCreateEditTasks(String teamId) =>
      permissionsFor(teamId).createEditTasks;
  bool canAssignTasks(String teamId) => permissionsFor(teamId).assignTasks;
  bool canDeleteTasks(String teamId) => permissionsFor(teamId).deleteTasks;
  bool canApproveTasks(String teamId) => permissionsFor(teamId).approveTasks;
  bool canInviteMembers(String teamId) => permissionsFor(teamId).inviteMembers;
  bool canViewAllTasks(String teamId) => permissionsFor(teamId).viewAllTasks;

  // Visible tasks respecting RBAC: Owners & roles with viewAllTasks see all; otherwise only own tasks.
  List<TaskItem> visibleTasksOf(String teamId) {
    final all = tasksOf(teamId);
    if (canViewAllTasks(teamId)) return all;
    return all.where((t) => t.assignee?.id == me.id).toList();
  }

  int openTasksCount(String teamId) =>
      visibleTasksOf(teamId).where((t) => t.status != TaskStatus.done).length;

  ({int done, int total}) progressOf(String teamId) {
    final list = tasksOf(teamId);
    return (
      done: list.where((t) => t.status == TaskStatus.done).length,
      total: list.length,
    );
  }

  // Status breakdown for visual analytics.
  Map<TaskStatus, int> statusBreakdown(String teamId) {
    final list = tasksOf(teamId);
    return {
      for (final s in TaskStatus.values)
        s: list.where((t) => t.status == s).length,
    };
  }

  int overdueCount(String teamId) =>
      tasksOf(teamId).where((t) => t.isOverdue).length;

  // Per-member assigned & completed task counts for workload analytics.
  List<({Member member, int done, int total})> memberWorkload(String teamId) {
    final team = findTeamById(teamId);
    if (team == null) return const [];
    final list = tasksOf(teamId);
    return [
      for (final m in team.members)
        (
          member: m,
          done: list
              .where(
                (t) => t.assignee?.id == m.id && t.status == TaskStatus.done,
              )
              .length,
          total: list.where((t) => t.assignee?.id == m.id).length,
        ),
    ];
  }

  int get peekNextNumber => _nextNumber;
  int nextNumber() => _nextNumber++;

  // Load real teams & tasks from Firestore (falls back to showcase data if none exist yet).
  Future<void> loadData({bool force = false}) async {
    if (_hasLoaded && !force) return;
    final repo = _repository;
    if (repo == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedMe = await repo.fetchCurrentMember();
      me = fetchedMe;
      final data = await repo.fetchTeamsAndTasks();
      if (data.teams.isNotEmpty) {
        _teams
          ..clear()
          ..addAll(data.teams);
        _tasks
          ..clear()
          ..addAll(data.tasks);
        final maxNum = _tasks.fold<int>(
          0,
          (prev, t) => t.number > prev ? t.number : prev,
        );
        if (maxNum >= _nextNumber) _nextNumber = maxNum + 1;
      } else {
        _seedFallback(currentUser: fetchedMe);
      }
      _hasLoaded = true;
    } catch (_) {
      _seedFallback();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Sync a newly accepted member from My Projects into the matching team.
  void syncMemberAdded({
    required String teamId,
    required Member member,
    String? teamName,
  }) {
    var idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1 && teamName != null && teamName.trim().isNotEmpty) {
      final needle = teamName.trim().toLowerCase();
      idx = _teams.indexWhere((t) => t.name.trim().toLowerCase() == needle);
    }
    if (idx == -1) return;
    final team = _teams[idx];
    if (team.members.any((m) => m.id == member.id)) return;
    final nextMembers = [...team.members, member];
    final nextSeats = nextMembers.length > team.totalSeats
        ? nextMembers.length
        : team.totalSeats;
    final remainingRoles = List<OpenRole>.from(team.openRoles);
    final roleIdx = remainingRoles.indexWhere(
      (r) => r.title.trim().toLowerCase() == member.role.trim().toLowerCase(),
    );
    if (roleIdx != -1) remainingRoles.removeAt(roleIdx);
    _teams[idx] = team.copyWith(
      members: nextMembers,
      totalSeats: nextSeats,
      openRoles: remainingRoles,
    );
    notifyListeners();
  }

  // Sync updated project metadata (title, seats, repoUrl) from My Projects.
  void syncProjectMetadata({
    required String teamId,
    String? previousName,
    String? name,
    int? totalSeats,
    String? repoUrl,
  }) {
    var idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1 && previousName != null && previousName.trim().isNotEmpty) {
      final needle = previousName.trim().toLowerCase();
      idx = _teams.indexWhere((t) => t.name.trim().toLowerCase() == needle);
    }
    if (idx == -1) return;
    _teams[idx] = _teams[idx].copyWith(
      name: name,
      totalSeats: totalSeats,
      repoUrl: repoUrl,
    );
    notifyListeners();
  }

  // Update workspace details & role permissions (Owner-only).
  Future<void> updateTeamSettings(
    String teamId, {
    String? repoUrl,
    String? sprint,
    String? version,
    DateTime? expectedEndDate,
    TeamSettings? settings,
  }) async {
    if (!isOwnerOf(teamId)) return;
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final updated = _teams[idx].copyWith(
      repoUrl: repoUrl,
      sprint: sprint,
      version: version,
      expectedEndDate: expectedEndDate,
      settings: settings,
    );
    _teams[idx] = updated;
    notifyListeners();
    if (repoUrl != null && ServiceLocator.isRegistered<MyProjectsCubit>()) {
      ServiceLocator.get<MyProjectsCubit>().syncFromTeam(
        projectId: teamId,
        repoUrl: updated.repoUrl,
      );
    }
    await _repository?.updateTeamSettings(updated);
  }

  // Toggle whether the Project Owner also acts as a Track Leader for a specific project track.
  Future<void> toggleOwnerTrackLeader(
    String teamId, {
    String? leaderTrack,
  }) async {
    if (!isOwnerOf(teamId)) return;
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = _teams[idx];
    var nextValue = false;
    final cleanTrack = leaderTrack?.trim();
    final updatedMembers = [
      for (final m in team.members)
        if (m.id == me.id && m.isOwner)
          () {
            nextValue = leaderTrack != null ? true : !m.alsoTrackLeader;
            return m.copyWith(
              alsoTrackLeader: nextValue,
              leaderTrack: nextValue ? cleanTrack : null,
              clearLeaderTrack: !nextValue,
            );
          }()
        else
          m,
    ];
    _teams[idx] = team.copyWith(members: updatedMembers);
    notifyListeners();
    await _repository?.updateMemberRole(
      teamId: teamId,
      memberId: me.id,
      role: TeamRole.owner,
      alsoTrackLeader: nextValue,
      leaderTrack: nextValue ? cleanTrack : null,
      clearLeaderTrack: !nextValue,
    );
  }

  // Change a member's team role between Track Leader (with optional project track) and Member.
  Future<void> setMemberRole(
    String teamId,
    String memberId,
    TeamRole role, {
    String? leaderTrack,
  }) async {
    if (!isOwnerOf(teamId) || role == TeamRole.owner) return;
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = _teams[idx];
    final cleanTrack = role == TeamRole.trackLeader ? leaderTrack?.trim() : null;
    final clearTrack = role == TeamRole.member;
    final updatedMembers = [
      for (final m in team.members)
        if (m.id == memberId && !m.isOwner)
          m.copyWith(
            teamRole: role,
            leaderTrack: cleanTrack,
            clearLeaderTrack: clearTrack,
          )
        else
          m,
    ];
    _teams[idx] = team.copyWith(members: updatedMembers);
    notifyListeners();
    await _repository?.updateMemberRole(
      teamId: teamId,
      memberId: memberId,
      role: role,
      leaderTrack: cleanTrack,
      clearLeaderTrack: clearTrack,
    );
  }

  // Remove a non-owner member from the team (Owner-only).
  Future<void> removeMember(String teamId, String memberId) async {
    if (!isOwnerOf(teamId)) return;
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = _teams[idx];
    final updatedMembers = team.members
        .where((m) => m.id != memberId || m.isOwner)
        .toList();
    _teams[idx] = team.copyWith(members: updatedMembers);
    // Unassign tasks that belonged to the removed member.
    for (final t in _tasks.where(
      (t) => t.teamId == teamId && t.assignee?.id == memberId,
    )) {
      t.assignee = null;
    }
    notifyListeners();
    if (ServiceLocator.isRegistered<MyProjectsCubit>()) {
      ServiceLocator.get<MyProjectsCubit>().syncFromTeam(
        projectId: teamId,
        membersCountDelta: -1,
      );
    }
    await _repository?.removeMember(teamId: teamId, memberId: memberId);
  }

  // Transfer Project Owner role to another team member (Owner-only).
  Future<void> transferOwnership(String teamId, String newOwnerId) async {
    if (!isOwnerOf(teamId) || newOwnerId == me.id) return;
    final idx = _teams.indexWhere((t) => t.id == teamId);
    if (idx == -1) return;
    final team = _teams[idx];
    final updatedMembers = [
      for (final m in team.members)
        if (m.id == newOwnerId)
          m.copyWith(teamRole: TeamRole.owner)
        else if (m.id == me.id)
          m.copyWith(teamRole: TeamRole.trackLeader)
        else
          m,
    ];
    _teams[idx] = team.copyWith(
      ownerId: newOwnerId,
      role: TeamRole.trackLeader.shortLabel,
      members: updatedMembers,
    );
    notifyListeners();
    await _repository?.transferOwnership(
      teamId: teamId,
      previousOwnerId: me.id,
      newOwnerId: newOwnerId,
    );
  }

  // Delete the team permanently (Owner-only).
  Future<void> deleteTeam(String teamId) async {
    if (!isOwnerOf(teamId)) return;
    _teams.removeWhere((t) => t.id == teamId);
    _tasks.removeWhere((t) => t.teamId == teamId);
    notifyListeners();
    await _repository?.deleteTeam(teamId);
  }

  // Create or update a task (requires createEditTasks permission).
  Future<void> saveTask(TaskItem task) async {
    if (!canCreateEditTasks(task.teamId)) return;
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) {
      _tasks.add(task);
    } else {
      _tasks[i] = task;
    }
    notifyListeners();
    await _repository?.saveTask(task);
  }

  // Delete a task (requires deleteTasks permission).
  Future<void> deleteTask(String teamId, String taskId) async {
    if (!canDeleteTasks(teamId)) return;
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
    await _repository?.deleteTask(teamId: teamId, taskId: taskId);
  }

  // Update task status with optional PR URL or review note.
  Future<void> setStatus(
    String taskId,
    TaskStatus status, {
    String? prUrl,
    String? reviewNote,
  }) async {
    final task = findTaskById(taskId);
    if (task == null) return;
    if (status == TaskStatus.done && !canApproveTasks(task.teamId)) return;

    task.status = status;
    if (prUrl != null && prUrl.trim().isNotEmpty) {
      task.prUrl = prUrl.trim();
    }
    if (reviewNote != null) {
      task.reviewNote = reviewNote.trim().isEmpty ? null : reviewNote.trim();
    }
    notifyListeners();
    await _repository?.saveTask(task);
  }

  // Toggle an acceptance criterion and persist.
  Future<void> toggleCriterion(String taskId, int index) async {
    final task = findTaskById(taskId);
    if (task == null || index < 0 || index >= task.criteria.length) return;
    task.criteria[index].done = !task.criteria[index].done;
    notifyListeners();
    await _repository?.saveTask(task);
  }

  // Leave a team locally and in Firestore.
  Future<void> leaveTeam(String id) async {
    _teams.removeWhere((t) => t.id == id);
    _tasks.removeWhere((t) => t.teamId == id);
    notifyListeners();
    await _repository?.leaveTeam(id);
  }

  // Reset user-scoped state on sign-out.
  void reset() {
    _hasLoaded = false;
    _teams.clear();
    _tasks.clear();
    _nextNumber = 104;
    _seedFallback();
    notifyListeners();
  }

  // Seed initial showcase data when no Firestore teams exist yet.
  void _seedFallback({Member? currentUser}) {
    me =
        currentUser ??
        const Member(
          id: 'u1',
          name: 'Alex Rivera',
          handle: '@alexrivera',
          role: 'Project Owner & BLE Lead',
          teamRole: TeamRole.owner,
        );
    final ownerMe = Member(
      id: me.id,
      name: me.name,
      handle: me.handle,
      role: me.role,
      teamRole: TeamRole.owner,
    );
    const sarah = Member(
      id: 'u2',
      name: 'Sarah Lin',
      handle: '@sarahlin_dev',
      role: 'UI/UX & Design Systems',
      teamRole: TeamRole.trackLeader,
      leaderTrack: 'UI/UX',
    );
    const marcus = Member(
      id: 'u3',
      name: 'Marcus Vance',
      handle: '@marcus_v',
      role: 'Flutter Client & State',
      teamRole: TeamRole.member,
    );
    const sofia = Member(
      id: 'u4',
      name: 'Sofia Chen',
      handle: '@sofia_c',
      role: 'QA & Test Automation',
      teamRole: TeamRole.member,
    );

    final now = DateTime.now();

    _teams
      ..clear()
      ..addAll([
        Team(
          id: 'eco',
          name: 'EcoTrack Mobile',
          subtitle: 'Active • Real-world',
          role: TeamRole.owner.shortLabel,
          sprint: 'Sprint 2',
          icon: Icons.eco_outlined,
          members: [ownerMe, sarah, marcus],
          totalSeats: 5,
          version: 'v2.4.0',
          repoUrl: 'https://github.com/ecotrack/mobile',
          ownerId: me.id,
          expectedEndDate: now.add(const Duration(days: 8)),
          projectTracks: const ['Flutter', 'Backend', 'UI/UX', 'QA'],
          openRoles: const [
            OpenRole(
              title: 'Backend / SQLite Architect',
              description:
                  'Local-first sync engine & telemetry persistence layer',
              level: 'Intermediate',
              hours: '8 hrs/wk',
              tech: 'SQLite & Drift',
            ),
            OpenRole(
              title: 'Integration & QA Contributor',
              description:
                  'Automated unit test runs, widget harnesses & edge cases',
              level: 'Beginner friendly',
              hours: '4 hrs/wk',
              tech: 'Integration Testing',
            ),
          ],
        ),
        Team(
          id: 'algo',
          name: 'AlgoViz Flutter',
          subtitle: 'Active • Learning',
          role: TeamRole.member.shortLabel,
          sprint: 'v1.2 Release',
          icon: Icons.account_tree_outlined,
          members: [
            sarah.copyWith(teamRole: TeamRole.owner),
            marcus.copyWith(teamRole: TeamRole.trackLeader),
            me.copyWith(teamRole: TeamRole.member),
          ],
          totalSeats: 4,
          version: 'v1.2.0',
          repoUrl: 'https://github.com/algoviz/flutter',
          ownerId: sarah.id,
          expectedEndDate: now.add(const Duration(days: 14)),
          openRoles: const [],
        ),
      ]);

    _tasks
      ..clear()
      ..addAll([
        TaskItem(
          id: 't12',
          teamId: 'eco',
          number: 12,
          title: 'Refactor BLE background isolate connection lifecycle',
          description: 'Ensure persistent peripheral handshake reconnects cleanly when Android battery saver triggers deep doze.',
          priority: Priority.high,
          status: TaskStatus.inProgress,
          assignee: ownerMe,
          dueDate: now.add(const Duration(days: 2)),
          tag: 'Architecture',
          epic: 'BLE & STATE MANAGEMENT',
          codePath: 'lib/core/ble/isolate_worker.dart',
          criteria: [
            Criterion('StreamController closed on dispose', done: true),
            Criterion('GATT disconnect timeout verified (5s)'),
            Criterion('Tested on Android 14 physical device'),
          ],
          comment: 'Added the missing GATT disconnect timeout spec...',
          commentBy: 'Sofia Chen',
        ),
        TaskItem(
          id: 't14',
          teamId: 'eco',
          number: 14,
          title: 'Implement telemetry sync charts with FL Chart',
          description: 'Render kilowatt-hour smoothing spline with real-time scrub interaction & export vector snapshots.',
          priority: Priority.medium,
          status: TaskStatus.inProgress,
          assignee: sarah,
          dueDate: now.add(const Duration(days: 8)),
          tag: 'UI/UX',
          epic: 'TELEMETRY',
          criteria: [
            Criterion('Chart scrubs at 60fps', done: true),
            Criterion('Export snapshot as PNG'),
          ],
        ),
        TaskItem(
          id: 't16',
          teamId: 'eco',
          number: 16,
          title: 'Profile SQLite WAL mode buffer allocations on cold start',
          priority: Priority.low,
          status: TaskStatus.todo,
          tag: 'Performance',
          epic: 'PERFORMANCE',
        ),
        TaskItem(
          id: 't17',
          teamId: 'eco',
          number: 17,
          title: 'Add dark mode tokens to design system',
          description: 'Map semantic color tokens for dark surfaces.',
          priority: Priority.medium,
          status: TaskStatus.todo,
          assignee: sarah,
          dueDate: now.add(const Duration(days: 12)),
          tag: 'UI/UX',
          epic: 'DESIGN SYSTEM',
        ),
        TaskItem(
          id: 't18',
          teamId: 'eco',
          number: 18,
          title: 'Write widget tests for onboarding flow',
          priority: Priority.low,
          status: TaskStatus.todo,
          assignee: sofia,
          dueDate: now.add(const Duration(days: 6)),
          tag: 'Testing',
          epic: 'QUALITY',
        ),
        TaskItem(
          id: 't11',
          teamId: 'eco',
          number: 11,
          title: 'Migrate state layer to ChangeNotifier',
          description:
              'Replace ad-hoc setState usage with a single source of truth.',
          priority: Priority.high,
          status: TaskStatus.inReview,
          assignee: marcus,
          dueDate: now.add(const Duration(days: 1)),
          tag: 'Architecture',
          epic: 'BLE & STATE MANAGEMENT',
          prUrl: 'https://github.com/ecotrack/mobile/pull/42',
          criteria: [
            Criterion('All screens migrated', done: true),
            Criterion('Unit tests passing', done: true),
          ],
        ),
        TaskItem(
          id: 't9',
          teamId: 'eco',
          number: 9,
          title: 'Set up CI pipeline',
          priority: Priority.medium,
          status: TaskStatus.done,
          assignee: ownerMe,
          tag: 'DevOps',
          epic: 'INFRA',
        ),
        TaskItem(
          id: 'a3',
          teamId: 'algo',
          number: 3,
          title: 'Animate quick sort partitions',
          description:
              'Highlight pivot swaps and partition boundaries smoothly.',
          priority: Priority.medium,
          status: TaskStatus.inProgress,
          assignee: me,
          dueDate: now.add(const Duration(days: 4)),
          tag: 'Visualization',
          epic: 'SORTING',
          criteria: [
            Criterion('Pivot color transition smooth', done: true),
            Criterion('Supports pause and step-back'),
          ],
        ),
        TaskItem(
          id: 'a4',
          teamId: 'algo',
          number: 4,
          title: 'Add speed slider to playback controls',
          priority: Priority.low,
          status: TaskStatus.todo,
          assignee: me,
          tag: 'UI/UX',
          epic: 'PLAYBACK',
        ),
        TaskItem(
          id: 'a5',
          teamId: 'algo',
          number: 5,
          title: 'Benchmark merge sort memory usage',
          priority: Priority.medium,
          status: TaskStatus.todo,
          assignee: marcus,
          tag: 'Performance',
          epic: 'SORTING',
        ),
      ]);
  }
}

// InheritedNotifier providing TeamsController down the widget tree.
class TeamsScope extends InheritedNotifier<TeamsController> {
  const TeamsScope({
    super.key,
    required TeamsController controller,
    required super.child,
  }) : super(notifier: controller);

  static TeamsController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TeamsScope>()!.notifier!;
}
