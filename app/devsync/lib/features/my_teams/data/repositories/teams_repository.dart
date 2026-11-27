import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/services/firebase/presence_service.dart';
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
  Future<({List<Team> teams, List<TaskItem> tasks})>
  fetchTeamsAndTasks() async {
    final uid = _auth.currentUserId;
    if (uid == null) return (teams: const <Team>[], tasks: const <TaskItem>[]);

    try {
      // Self-heal: ensure every ongoing project owned by this user has a teams/{projectId} doc,
      // and every accepted applicant is present in teams/{projectId}/members & memberIds.
      await _ensureTeamsForOwnedOngoingProjects(uid);
      await _syncAcceptedApplicantsToTeams(uid);

      final teamDocs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.teamsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldMemberIds, arrayContains: uid),
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
        final members = _sortMembers(
          memberDocs.map(Member.fromFirestore).toList(),
          ownerId: ownerId,
        );

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

        final rawTracks =
            doc[FirebaseConstants.fieldTrackKeys] ??
            doc[FirebaseConstants.fieldOpenTrackKeys];
        final projectTracks = <String>[
          if (rawTracks is Iterable)
            for (final t in rawTracks) t.toString(),
        ];

        teams.add(
          Team(
            id: teamId,
            name:
                (doc[FirebaseConstants.fieldProjectTitle] ??
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
            projectTracks: projectTracks,
          ),
        );
      }

      return (teams: teams, tasks: tasks);
    } catch (_) {
      return (teams: const <Team>[], tasks: const <TaskItem>[]);
    }
  }

  // Ensure every active/ongoing project owned by uid has a matching teams/{projectId} workspace.
  Future<void> _ensureTeamsForOwnedOngoingProjects(String uid) async {
    try {
      final ownedProjects = await _firestore.getCollection(
        collectionPath: FirebaseConstants.projectsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
      );
      if (ownedProjects.isEmpty) return;

      Map<String, dynamic>? ownerDoc;
      for (final p in ownedProjects) {
        final pid = (p['id'] ?? '').toString();
        if (pid.isEmpty) continue;
        final status = (p[FirebaseConstants.fieldStatus] ?? 'open')
            .toString()
            .toLowerCase();
        if (status == 'draft' ||
            status == 'completed' ||
            status == 'archived') {
          continue;
        }

        final existingTeam = await _firestore.getDocument(
          collectionPath: FirebaseConstants.teamsCollection,
          docId: pid,
        );
        final rawMemberIds = existingTeam?[FirebaseConstants.fieldMemberIds];
        final hasOwner =
            rawMemberIds is Iterable &&
            rawMemberIds.map((e) => e.toString()).contains(uid);
        if (existingTeam != null && hasOwner) continue;

        ownerDoc ??= await _firestore.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: uid,
        );
        final ownerName =
            (ownerDoc?[FirebaseConstants.fieldName] ?? currentUserName)
                .toString();
        final ownerHandle =
            (ownerDoc?[FirebaseConstants.fieldPublicId] ??
                    ownerName.toLowerCase().replaceAll(' ', ''))
                .toString();
        final ownerTrack = (ownerDoc?[FirebaseConstants.fieldTrack] ?? 'Owner')
            .toString();

        await _firestore.setDocument(
          collectionPath: FirebaseConstants.teamsCollection,
          docId: pid,
          data: {
            FirebaseConstants.fieldProjectId: pid,
            FirebaseConstants.fieldProjectTitle:
                (p[FirebaseConstants.fieldTitle] ?? 'Team Workspace')
                    .toString(),
            FirebaseConstants.fieldOwnerId: uid,
            FirebaseConstants.fieldMemberIds: FieldValue.arrayUnion([uid]),
            FirebaseConstants.fieldTeamSize:
                (p[FirebaseConstants.fieldTeamSize] is num)
                ? (p[FirebaseConstants.fieldTeamSize] as num).toInt()
                : 4,
            if (p[FirebaseConstants.fieldOpenTrackKeys] != null)
              FirebaseConstants.fieldOpenTrackKeys:
                  p[FirebaseConstants.fieldOpenTrackKeys],
            if (p[FirebaseConstants.fieldExpectedEndDate] != null)
              FirebaseConstants.fieldExpectedEndDate:
                  p[FirebaseConstants.fieldExpectedEndDate],
            if (p['repoUrl'] != null) 'repoUrl': p['repoUrl'],
            if (p['defaultBranch'] != null) 'defaultBranch': p['defaultBranch'],
            FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
            if (existingTeam == null)
              FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
          },
          merge: true,
        );

        await _firestore.setDocument(
          collectionPath:
              '${FirebaseConstants.teamsCollection}/$pid/${FirebaseConstants.membersCollection}',
          docId: uid,
          data: {
            FirebaseConstants.fieldUid: uid,
            FirebaseConstants.fieldName: ownerName,
            'username': ownerHandle,
            FirebaseConstants.fieldTrack: ownerTrack,
            'teamRole': 'owner',
            FirebaseConstants.fieldJoinedAt: _firestore.serverTimestamp,
          },
          merge: true,
        );
      }
    } catch (_) {}
  }

  // Ensure every accepted join request for this owner's projects has a member doc in teams/{pid}/members.
  Future<void> _syncAcceptedApplicantsToTeams(String uid) async {
    try {
      final accepted = await _firestore.getCollection(
        collectionPath: FirebaseConstants.requestsCollection,
        queryBuilder: (q) => q
            .where(FirebaseConstants.fieldOwnerId, isEqualTo: uid)
            .where(FirebaseConstants.fieldStatus, isEqualTo: 'accepted'),
      );
      if (accepted.isEmpty) return;

      for (final req in accepted) {
        final pid = (req[FirebaseConstants.fieldProjectId] ?? '').toString();
        final applicantUid = (req[FirebaseConstants.fieldApplicantId] ?? '')
            .toString();
        if (pid.isEmpty || applicantUid.isEmpty) continue;

        final membersPath =
            '${FirebaseConstants.teamsCollection}/$pid/${FirebaseConstants.membersCollection}';
        final existingMember = await _firestore.getDocument(
          collectionPath: membersPath,
          docId: applicantUid,
        );

        if (existingMember == null) {
          final snap = req[FirebaseConstants.fieldApplicantSnapshot] is Map
              ? Map<String, dynamic>.from(
                  req[FirebaseConstants.fieldApplicantSnapshot] as Map,
                )
              : const <String, dynamic>{};
          final userDoc = await _firestore.getDocument(
            collectionPath: FirebaseConstants.usersCollection,
            docId: applicantUid,
          );
          final name =
              (userDoc?[FirebaseConstants.fieldName] ??
                      snap[FirebaseConstants.fieldName] ??
                      'Member')
                  .toString();
          final handle =
              (userDoc?[FirebaseConstants.fieldPublicId] ??
                      snap[FirebaseConstants.fieldPublicId] ??
                      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
                  .toString();
          final track =
              (req[FirebaseConstants.fieldTrack] ??
                      userDoc?[FirebaseConstants.fieldTrack] ??
                      'Member')
                  .toString();

          await _firestore.setDocument(
            collectionPath: membersPath,
            docId: applicantUid,
            data: {
              FirebaseConstants.fieldUid: applicantUid,
              FirebaseConstants.fieldName: name,
              'username': handle,
              FirebaseConstants.fieldTrack: track,
              'teamRole': 'member',
              FirebaseConstants.fieldIsOwner: false,
              FirebaseConstants.fieldJoinedAt: _firestore.serverTimestamp,
            },
            merge: true,
          );
        }

        await _firestore.setDocument(
          collectionPath: FirebaseConstants.teamsCollection,
          docId: pid,
          data: {
            FirebaseConstants.fieldMemberIds: FieldValue.arrayUnion([
              applicantUid,
            ]),
            FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
          },
          merge: true,
        );

        // Keep projects/{pid}.filledCount and openTrackKeys in sync with real team members.
        try {
          final allMembers = await _firestore.getCollection(
            collectionPath: membersPath,
          );
          final pDoc = await _firestore.getDocument(
            collectionPath: FirebaseConstants.projectsCollection,
            docId: pid,
          );
          if (pDoc != null) {
            String norm(String v) =>
                v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
            final filledTrack = norm(
              (req[FirebaseConstants.fieldTrack] ?? '').toString(),
            );
            final rawOpen = pDoc[FirebaseConstants.fieldOpenTrackKeys];
            final openKeys = rawOpen is Iterable
                ? rawOpen.map((e) => e.toString()).toList()
                : <String>[];
            final filteredOpen = filledTrack.isEmpty
                ? openKeys
                : openKeys.where((k) => norm(k) != filledTrack).toList();
            final currentFilled =
                (pDoc[FirebaseConstants.fieldFilledCount] is num)
                ? (pDoc[FirebaseConstants.fieldFilledCount] as num).toInt()
                : 1;
            if (allMembers.length > currentFilled ||
                filteredOpen.length != openKeys.length) {
              await _firestore.updateDocument(
                collectionPath: FirebaseConstants.projectsCollection,
                docId: pid,
                data: {
                  FirebaseConstants.fieldFilledCount:
                      allMembers.length > currentFilled
                      ? allMembers.length
                      : currentFilled,
                  FirebaseConstants.fieldOpenTrackKeys: filteredOpen,
                  FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
                },
              );
            }
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  // Real-time stream of team documents where the current user is a member.
  Stream<List<Map<String, dynamic>>> watchTeamDocs() {
    final uid = _auth.currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore.collectionStream(
      collectionPath: FirebaseConstants.teamsCollection,
      queryBuilder: (q) =>
          q.where(FirebaseConstants.fieldMemberIds, arrayContains: uid),
    );
  }

  // Real-time stream of members for a specific team.
  Stream<List<Member>> watchTeamMembers(String teamId) {
    return _firestore
        .collectionStream(
          collectionPath:
              '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.membersCollection}',
        )
        .map((docs) => docs.map(Member.fromFirestore).toList());
  }

  // Real-time stream of raw task docs for a specific team.
  Stream<List<Map<String, dynamic>>> watchTeamTaskDocs(String teamId) {
    return _firestore.collectionStream(
      collectionPath:
          '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.tasksCollection}',
    );
  }

  // Real-time stream of currently online user IDs.
  Stream<Set<String>> watchOnlineUserIds() {
    return _firestore
        .collectionStream(
          collectionPath: FirebaseConstants.usersCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldIsOnline, isEqualTo: true),
        )
        .map((docs) {
          final online = <String>{};
          for (final d in docs) {
            final uid = (d['id'] ?? d[FirebaseConstants.fieldUid] ?? '')
                .toString();
            if (uid.isEmpty) continue;
            final rawLast = d[FirebaseConstants.fieldLastSeen];
            DateTime? lastSeen;
            if (rawLast is Timestamp) lastSeen = rawLast.toDate();
            if (PresenceService.isRecentlyOnline(true, lastSeen)) {
              online.add(uid);
            }
          }
          return online;
        });
  }

  // Sort team members so Owner is always first, then Track Leaders, then Members.
  List<Member> _sortMembers(List<Member> members, {required String ownerId}) {
    int rank(Member m) {
      if ((ownerId.isNotEmpty && m.id == ownerId) ||
          m.effectiveRole == TeamRole.owner) {
        return 0;
      }
      if (m.effectiveRole == TeamRole.trackLeader) return 1;
      return 2;
    }

    final sorted = List<Member>.from(members);
    sorted.sort((a, b) {
      final cmp = rank(a).compareTo(rank(b));
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  // Build a Team model from a Firestore doc + current member list.
  Team teamFromDoc(
    Map<String, dynamic> doc, {
    required List<Member> members,
    required String uid,
  }) {
    final teamId = (doc['id'] ?? '').toString();
    final ownerId = (doc[FirebaseConstants.fieldOwnerId] ?? '').toString();
    final sortedMembers = _sortMembers(members, ownerId: ownerId);
    final myMember = sortedMembers.where((m) => m.id == uid).firstOrNull;
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

    final rawTracks =
        doc[FirebaseConstants.fieldTrackKeys] ??
        doc[FirebaseConstants.fieldOpenTrackKeys];
    final projectTracks = <String>[
      if (rawTracks is Iterable)
        for (final t in rawTracks) t.toString(),
    ];

    return Team(
      id: teamId,
      name:
          (doc[FirebaseConstants.fieldProjectTitle] ??
                  doc[FirebaseConstants.fieldName] ??
                  'Team Workspace')
              .toString(),
      subtitle: (doc['subtitle'] ?? 'Active • Real-world').toString(),
      role: myRole.shortLabel,
      sprint: (doc['sprint'] ?? 'Active Sprint').toString(),
      icon: Icons.workspaces_outline,
      members: sortedMembers,
      totalSeats: (doc[FirebaseConstants.fieldTeamSize] is num)
          ? (doc[FirebaseConstants.fieldTeamSize] as num).toInt()
          : (sortedMembers.length < 4 ? 4 : sortedMembers.length),
      openRoles: const [],
      version: (doc['version'] ?? 'v1.0.0').toString(),
      repoUrl: (doc['repoUrl'] ?? 'https://github.com/devsync/project')
          .toString(),
      ownerId: ownerId,
      expectedEndDate: endDate,
      settings: settings,
      projectTracks: projectTracks,
    );
  }

  // Persist workspace metadata & role permissions to teams/{teamId} and mirror to projects/{teamId}.
  Future<void> updateTeamSettings(Team team) async {
    try {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: team.id,
        data: {
          'repoUrl': team.repoUrl,
          'sprint': team.sprint,
          'version': team.version,
          FirebaseConstants.fieldExpectedEndDate: team.expectedEndDate
              ?.toIso8601String(),
          'settings': team.settings.toMap(),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
        merge: true,
      );
      final cleanRepo = team.repoUrl.trim().replaceAll(RegExp(r'/+$'), '');
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: team.id,
        data: {
          'repoUrl': team.repoUrl,
          if (cleanRepo.isNotEmpty)
            'cloneUrl': cleanRepo.endsWith('.git')
                ? cleanRepo
                : '$cleanRepo.git',
          if (team.expectedEndDate != null)
            FirebaseConstants.fieldExpectedEndDate: team.expectedEndDate!
                .toIso8601String(),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Update a team member's role and optional leader track in teams/{teamId}/members/{memberId}.
  Future<void> updateMemberRole({
    required String teamId,
    required String memberId,
    required TeamRole role,
    bool? alsoTrackLeader,
    String? leaderTrack,
    bool clearLeaderTrack = false,
  }) async {
    try {
      await _firestore.setDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/$teamId/${FirebaseConstants.membersCollection}',
        docId: memberId,
        data: {
          'teamRole': role.name,
          FirebaseConstants.fieldIsOwner: role == TeamRole.owner,
          'alsoTrackLeader': ?alsoTrackLeader,
          if (clearLeaderTrack)
            'leaderTrack': null
          else
            'leaderTrack': ?leaderTrack,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Remove a member from teams/{teamId} and decrement projects/{teamId}.filledCount.
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
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: teamId,
        data: {
          FirebaseConstants.fieldFilledCount: FieldValue.increment(-1),
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        },
        merge: true,
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
