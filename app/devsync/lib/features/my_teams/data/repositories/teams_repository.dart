import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:flutter/material.dart';

// Firestore persistence layer for teams, settings, roles, members, and tasks.
class TeamsRepository {
  TeamsRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  }) : _firestore = firestoreService,
       _auth = authService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  String? get currentUserId => _auth.currentUserId;
  String get currentUserName =>
      _auth.currentUser?.displayName?.trim().isNotEmpty == true
      ? _auth.currentUser!.displayName!.trim()
      : 'Developer';

  // Load current user's Member snapshot from users/{uid}.
  Future<Member> fetchCurrentMember() async {
    final uid = _auth.currentUserId;
    if (uid == null) {
      return const Member(
        id: 'guest',
        name: 'Developer',
        handle: '@developer',
        role: 'Contributor',
      );
    }
    try {
      final doc = await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      if (doc != null) {
        return Member.fromFirestore({...doc, FirebaseConstants.fieldUid: uid});
      }
    } catch (_) {}
    return Member(
      id: uid,
      name: currentUserName,
      handle: '@${currentUserName.toLowerCase().replaceAll(' ', '')}',
      role: 'Contributor',
    );
  }

  // Load all teams where the current user is a member, along with members & tasks.
  Future<({List<Team> teams, List<TaskItem> tasks})> fetchTeamsAndTasks() async {
    final uid = _auth.currentUserId;
    if (uid == null) return (teams: const <Team>[], tasks: const <TaskItem>[]);

    try {
      final teamDocs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.teamsCollection,
        queryBuilder: (q) => q.where(
          FirebaseConstants.fieldMemberIds,
          arrayContains: uid,
        ),
      );
      if (teamDocs.isEmpty) {
        return (teams: const <Team>[], tasks: const <TaskItem>[]);
      }

      final teams = <Team>[];
      final tasks = <TaskItem>[];

      for (final doc in teamDocs) {
        final teamId = (doc['id'] ?? '').toString();
        if (teamId.isEmpty) continue;

        final ownerId = (doc[FirebaseConstants.fieldOwnerId] ?? '').toString();
        final membersPath =
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.membersCollection}';
        final tasksPath =
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.tasksCollection}';

        final memberDocs = await _firestore.getCollection(
          collectionPath: membersPath,
        );
        final members = memberDocs.map(Member.fromFirestore).toList();

        final taskDocs = await _firestore.getCollection(
          collectionPath: tasksPath,
        );
        for (var i = 0; i < taskDocs.length; i++) {
          tasks.add(
            TaskItem.fromFirestore(
              taskDocs[i],
              teamId: teamId,
              members: members,
              fallbackNumber: i + 1,
            ),
          );
        }

        final myMember = members.where((m) => m.id == uid).firstOrNull;
        final myRole = ownerId == uid
            ? TeamRole.owner
            : (myMember?.effectiveRole ?? TeamRole.member);

        final rawEnd = doc[FirebaseConstants.fieldExpectedEndDate];
        DateTime? endDate;
        if (rawEnd is Timestamp) {
          endDate = rawEnd.toDate();
        } else if (rawEnd is String) {
          endDate = DateTime.tryParse(rawEnd);
        }

        final rawSettings = doc['settings'];
        final settings = TeamSettings.fromMap(
          rawSettings is Map ? Map<String, dynamic>.from(rawSettings) : null,
        );

        teams.add(
          Team(
            id: teamId,
            name: (doc[FirebaseConstants.fieldProjectTitle] ??
                    doc[FirebaseConstants.fieldName] ??
                    'Team Workspace')
                .toString(),
            subtitle: (doc['subtitle'] ?? 'Active • Real-world').toString(),
            role: myRole.shortLabel,
            sprint: (doc['sprint'] ?? 'Active Sprint').toString(),
            icon: Icons.workspaces_outline,
            members: members,
            totalSeats: (doc[FirebaseConstants.fieldTeamSize] is num)
                ? (doc[FirebaseConstants.fieldTeamSize] as num).toInt()
                : (members.length < 4 ? 4 : members.length),
            openRoles: const [],
            version: (doc['version'] ?? 'v1.0.0').toString(),
            repoUrl: (doc['repoUrl'] ?? 'https://github.com/devsync/project')
                .toString(),
            ownerId: ownerId,
            expectedEndDate: endDate,
            settings: settings,
          ),
        );
      }

      return (teams: teams, tasks: tasks);
    } catch (_) {
      return (teams: const <Team>[], tasks: const <TaskItem>[]);
    }
  }

  // Persist workspace metadata & role permissions to teams/{teamId}.
  Future<void> updateTeamSettings(Team team) async {
    try {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: team.id,
        data: {
          'repoUrl': team.repoUrl,
          'sprint': team.sprint,
          'version': team.version,
          FirebaseConstants.fieldExpectedEndDate:
              team.expectedEndDate?.toIso8601String(),
          'settings': team.settings.toMap(),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Update a team member's role in teams/{teamId}/members/{memberId}.
  Future<void> updateMemberRole({
    required String teamId,
    required String memberId,
    required TeamRole role,
    bool? alsoTrackLeader,
  }) async {
    try {
      await _firestore.setDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.membersCollection}',
        docId: memberId,
        data: {
          'teamRole': role.name,
          FirebaseConstants.fieldIsOwner: role == TeamRole.owner,
          if (alsoTrackLeader != null) 'alsoTrackLeader': alsoTrackLeader,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Remove a member from teams/{teamId}.
  Future<void> removeMember({
    required String teamId,
    required String memberId,
  }) async {
    try {
      await _firestore.deleteDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.membersCollection}',
        docId: memberId,
      );
      await _firestore.updateDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: teamId,
        data: {
          FirebaseConstants.fieldMemberIds: FieldValue.arrayRemove([memberId]),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
      );
    } catch (_) {}
  }

  // Transfer ownership to another member in Firestore.
  Future<void> transferOwnership({
    required String teamId,
    required String previousOwnerId,
    required String newOwnerId,
  }) async {
    try {
      await _firestore.updateDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: teamId,
        data: {
          FirebaseConstants.fieldOwnerId: newOwnerId,
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
      );
      await updateMemberRole(
        teamId: teamId,
        memberId: previousOwnerId,
        role: TeamRole.trackLeader,
      );
      await updateMemberRole(
        teamId: teamId,
        memberId: newOwnerId,
        role: TeamRole.owner,
      );
    } catch (_) {}
  }

  // Delete an entire team document in Firestore.
  Future<void> deleteTeam(String teamId) async {
    try {
      await _firestore.deleteDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: teamId,
      );
    } catch (_) {}
  }

  // Persist a created or updated task to teams/{teamId}/tasks/{taskId}.
  Future<void> saveTask(TaskItem task) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      await _firestore.setDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/${task.teamId}/${FirebaseConstants.tasksCollection}',
        docId: task.id,
        data: {
          ...task.toFirestore(createdBy: uid),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Delete a task from teams/{teamId}/tasks/{taskId}.
  Future<void> deleteTask({
    required String teamId,
    required String taskId,
  }) async {
    try {
      await _firestore.deleteDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.tasksCollection}',
        docId: taskId,
      );
    } catch (_) {}
  }

  // Remove the current user from teams/{teamId} and its members subcollection.
  Future<void> leaveTeam(String teamId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await removeMember(teamId: teamId, memberId: uid);
  }
}
