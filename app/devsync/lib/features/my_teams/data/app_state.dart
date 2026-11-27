import 'dart:async';

import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/data/repositories/teams_repository.dart';
import 'package:flutter/material.dart';

// Central state controller for My Teams, Task Board, Role-Based Permissions, and real-time Firestore sync.
class TeamsController extends ChangeNotifier {
  TeamsController({TeamsRepository? repository}) : _repository = repository {
    me = const Member(
      id: 'guest',
      name: 'Developer',
      handle: '@developer',
      role: 'Contributor',
    );
  }

  final TeamsRepository? _repository;

  bool isLoading = false;
  bool _hasLoaded = false;

  late Member me;
  final List<Team> _teams = [];
  final List<TaskItem> _tasks = [];
  Set<String> _onlineUserIds = {};
  int _nextNumber = 104;

  // Real-time stream subscriptions (cleaned up on reset/dispose).
  StreamSubscription<List<Map<String, dynamic>>>? _teamsSub;
  StreamSubscription<Set<String>>? _onlineSub;
  final Map<String, StreamSubscription<List<Member>>> _memberSubs = {};
  final Map<String, StreamSubscription<List<Map<String, dynamic>>>> _taskSubs =
      {};
  final Map<String, Map<String, dynamic>> _rawTeamDocs = {};
  final Map<String, List<Member>> _liveMembers = {};
  final Map<String, List<Map<String, dynamic>>> _rawTaskDocs = {};

  List<Team> get teams => List.unmodifiable(_teams);

  // Whether a team member is currently online.
  bool isMemberOnline(String memberId) =>
      memberId == me.id || _onlineUserIds.contains(memberId);

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
      _hasLoaded = true;
      _startRealtimeStreams();
    } catch (_) {
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Subscribe to real-time Firestore streams for teams, members, tasks, and online users.
  void _startRealtimeStreams() {
    final repo = _repository;
    final uid = repo?.currentUserId;
    if (repo == null || uid == null) return;

    _cancelStreams();

    _onlineSub = repo.watchOnlineUserIds().listen(
      (ids) {
        Timer.run(() {
          _onlineUserIds = ids;
          notifyListeners();
        });
      },
      onError: (_) {},
    );

    _teamsSub = repo.watchTeamDocs().listen(
      (docs) {
        Timer.run(() {
          final activeIds = <String>{};
          for (final doc in docs) {
            final teamId = (doc['id'] ?? '').toString();
            if (teamId.isEmpty) continue;
            activeIds.add(teamId);
            _rawTeamDocs[teamId] = doc;

            if (!_memberSubs.containsKey(teamId)) {
              _memberSubs[teamId] = repo.watchTeamMembers(teamId).listen(
                (members) {
                  Timer.run(() {
                    _liveMembers[teamId] = members;
                    _rebuildFromStreams(uid);
                  });
                },
                onError: (_) {},
              );
            }
            if (!_taskSubs.containsKey(teamId)) {
              _taskSubs[teamId] = repo.watchTeamTaskDocs(teamId).listen(
                (taskDocs) {
                  Timer.run(() {
                    _rawTaskDocs[teamId] = taskDocs;
                    _rebuildFromStreams(uid);
                  });
                },
                onError: (_) {},
              );
            }
          }

          // Clean up subscriptions for teams the user left or that were deleted.
          final staleIds = _memberSubs.keys
              .where((id) => !activeIds.contains(id))
              .toList();
          for (final stale in staleIds) {
            _memberSubs.remove(stale)?.cancel();
            _taskSubs.remove(stale)?.cancel();
            _rawTeamDocs.remove(stale);
            _liveMembers.remove(stale);
            _rawTaskDocs.remove(stale);
          }

          _rebuildFromStreams(uid);
        });
      },
      onError: (_) {},
    );
  }

  void _rebuildFromStreams(String uid) {
    final repo = _repository;
    if (repo == null) return;

    final nextTeams = <Team>[];
    final nextTasks = <TaskItem>[];

    for (final entry in _rawTeamDocs.entries) {
      final teamId = entry.key;
      final existing = findTeamById(teamId);
      final members = _liveMembers[teamId] ?? existing?.members ?? const <Member>[];
      nextTeams.add(repo.teamFromDoc(entry.value, members: members, uid: uid));

      final taskDocs = _rawTaskDocs[teamId];
      if (taskDocs != null) {
        for (var i = 0; i < taskDocs.length; i++) {
          nextTasks.add(
            TaskItem.fromFirestore(
              taskDocs[i],
              teamId: teamId,
              members: members,
              fallbackNumber: i + 1,
            ),
          );
        }
      } else {
        nextTasks.addAll(_tasks.where((t) => t.teamId == teamId));
      }
    }

    _teams
      ..clear()
      ..addAll(nextTeams);
    _tasks
      ..clear()
      ..addAll(nextTasks);
    final maxNum = _tasks.fold<int>(
      0,
      (prev, t) => t.number > prev ? t.number : prev,
    );
    if (maxNum >= _nextNumber) _nextNumber = maxNum + 1;
    notifyListeners();
  }

  void _cancelStreams() {
    _teamsSub?.cancel();
    _teamsSub = null;
    _onlineSub?.cancel();
    _onlineSub = null;
    for (final s in _memberSubs.values) {
      s.cancel();
    }
    _memberSubs.clear();
    for (final s in _taskSubs.values) {
      s.cancel();
    }
    _taskSubs.clear();
    _rawTeamDocs.clear();
    _liveMembers.clear();
    _rawTaskDocs.clear();
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

  // Reset user-scoped state and cancel real-time streams on sign-out.
  void reset() {
    _cancelStreams();
    _hasLoaded = false;
    _onlineUserIds = {};
    _teams.clear();
    _tasks.clear();
    _nextNumber = 104;
    me = const Member(
      id: 'guest',
      name: 'Developer',
      handle: '@developer',
      role: 'Contributor',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelStreams();
    super.dispose();
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
