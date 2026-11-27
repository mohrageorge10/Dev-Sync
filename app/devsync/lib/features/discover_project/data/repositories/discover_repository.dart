import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:flutter/material.dart';

// Unified repository for discovering projects, developers, bookmarks, applications, and invites.
class DiscoverRepository {
  DiscoverRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  }) : _firestore = firestoreService,
       _auth = authService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  // Fetch current user profile summary (name, strength, tracks, and skills).
  Future<
    ({
      String userName,
      double profileStrength,
      String? userTrack,
      List<String> secondaryTracks,
      List<String> userSkills,
    })
  >
  fetchUserSummary() async {
    final uid = _auth.currentUserId;
    if (uid == null) {
      return (
        userName: 'Alex',
        profileStrength: 0.6,
        userTrack: null,
        secondaryTracks: const <String>[],
        userSkills: const <String>[],
      );
    }

    try {
      final doc = await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      if (doc != null) {
        final name =
            (doc[FirebaseConstants.fieldName] ??
                    _auth.currentUser?.displayName ??
                    'Developer')
                .toString()
                .split(' ')
                .first;

        final rawTrack = doc[FirebaseConstants.fieldTrack]?.toString();
        final userTrack = (rawTrack != null && rawTrack.trim().isNotEmpty)
            ? UserTrackX.fromName(rawTrack).label
            : null;

        final rawSecondary = doc['secondaryTracks'];
        final secondaryTracks = <String>[
          if (rawSecondary is Iterable)
            for (final t in rawSecondary) t.toString(),
        ];

        final rawSkills = doc[FirebaseConstants.fieldSkills];
        final userSkills = <String>[
          if (rawSkills is Iterable)
            for (final s in rawSkills) s.toString(),
        ];

        var completed = 0;
        final hasBasic =
            (doc[FirebaseConstants.fieldName] ?? '').toString().trim().isNotEmpty &&
            (doc['username'] ?? '').toString().trim().length >= 3;
        if (hasBasic) completed++;
        if (userTrack != null &&
            (doc[FirebaseConstants.fieldLevel] ?? '').toString().trim().isNotEmpty) {
          completed++;
        }
        if (userSkills.isNotEmpty) completed++;
        final rawSoft = doc[FirebaseConstants.fieldSoftSkills];
        if (rawSoft is Iterable && rawSoft.isNotEmpty) completed++;
        final hasCv =
            (doc[FirebaseConstants.fieldCvFileName] ?? '').toString().isNotEmpty ||
            (doc[FirebaseConstants.fieldCvUrl] ?? '').toString().isNotEmpty;
        if (hasCv) completed++;
        if ((doc[FirebaseConstants.fieldPortfolioUrl] ?? '').toString().trim().isNotEmpty) {
          completed++;
        }
        if ((doc[FirebaseConstants.fieldLinkedinUrl] ?? '').toString().trim().isNotEmpty) {
          completed++;
        }
        if (doc[FirebaseConstants.fieldGithubConnected] == true) completed++;
        return (
          userName: name,
          profileStrength: (completed / 8).clamp(0.0, 1.0),
          userTrack: userTrack,
          secondaryTracks: secondaryTracks,
          userSkills: userSkills,
        );
      }
    } catch (_) {}

    final fallbackName = (_auth.currentUser?.displayName ?? 'Alex')
        .split(' ')
        .first;
    return (
      userName: fallbackName,
      profileStrength: 0.6,
      userTrack: null,
      secondaryTracks: const <String>[],
      userSkills: const <String>[],
    );
  }

  // Current authenticated user ID.
  String? get currentUserId => _auth.currentUserId;

  bool _isDiscoverableProject(Map<String, dynamic> d) {
    final status =
        (d[FirebaseConstants.fieldStatus] ?? 'open').toString().toLowerCase();
    return status != ProjectStatus.draft.name &&
        status != 'completed' &&
        status != 'shipped' &&
        status != 'archived';
  }

  // Fetch active discoverable projects from Firestore (excludes draft/completed/shipped/archived).
  Future<List<ProjectModel>> fetchProjects() async {
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.projectsCollection,
      );
      return docs
          .where(_isDiscoverableProject)
          .map(ProjectModel.fromFirestore)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // Fetch developers from Firestore (real data only).
  Future<List<DeveloperModel>> fetchDevelopers() async {
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.usersCollection,
      );
      final uid = _auth.currentUserId;
      return docs
          .where((d) => (d['id'] ?? d[FirebaseConstants.fieldUid]) != uid)
          .map(DeveloperModel.fromFirestore)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // Real-time stream of active discoverable projects in Firestore.
  Stream<List<ProjectModel>> watchProjects() {
    return _firestore
        .collectionStream(collectionPath: FirebaseConstants.projectsCollection)
        .map(
          (docs) => docs
              .where(_isDiscoverableProject)
              .map(ProjectModel.fromFirestore)
              .toList(),
        );
  }

  // Fetch real public projects (owned or joined, including completed/shipped with logos & awards).
  Future<List<PortfolioProjectData>> fetchDeveloperPublicProjects(
    String developerId,
  ) async {
    if (developerId.isEmpty) return const [];
    try {
      final byId = <String, ({Map<String, dynamic> doc, bool isOwner})>{};

      final ownedDocs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.projectsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldOwnerId, isEqualTo: developerId),
      );
      for (final d in ownedDocs) {
        final id = (d['id'] ?? '').toString();
        final status =
            (d[FirebaseConstants.fieldStatus] ?? 'open').toString().toLowerCase();
        if (id.isEmpty || status == 'draft') continue;
        byId[id] = (doc: d, isOwner: true);
      }

      final teamDocs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.teamsCollection,
        queryBuilder: (q) => q.where(
          FirebaseConstants.fieldMemberIds,
          arrayContains: developerId,
        ),
      );
      for (final t in teamDocs) {
        final pid =
            (t[FirebaseConstants.fieldProjectId] ?? t['id'] ?? '').toString();
        if (pid.isEmpty || byId.containsKey(pid)) continue;
        final pDoc = await _firestore.getDocument(
          collectionPath: FirebaseConstants.projectsCollection,
          docId: pid,
        );
        if (pDoc == null) continue;
        final status = (pDoc[FirebaseConstants.fieldStatus] ?? 'open')
            .toString()
            .toLowerCase();
        if (status == 'draft') continue;
        byId[pid] = (doc: {...pDoc, 'id': pid}, isOwner: false);
      }

      return byId.values.map((entry) {
        final d = entry.doc;
        final status =
            (d[FirebaseConstants.fieldStatus] ?? 'open').toString().toLowerCase();
        final outcome = (d['outcome'] ?? status).toString().toLowerCase();
        final isCompleted =
            status == 'completed' || status == 'shipped' || status == 'archived';
        final statusLabel = switch (outcome) {
          'shipped' => 'Shipped Product',
          'completed' => 'Completed',
          'archived' => 'Archived',
          _ => 'Active',
        };
        final rawType = (d[FirebaseConstants.fieldType] ?? 'REAL-WORLD')
            .toString()
            .toUpperCase();
        final filled = (d[FirebaseConstants.fieldFilledCount] is num)
            ? (d[FirebaseConstants.fieldFilledCount] as num).toInt()
            : 1;
        final rawAwards = d['awards'];
        final awards = rawAwards is Iterable
            ? rawAwards
                  .map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
            : const <String>[];
        final rawTags = d[FirebaseConstants.fieldTechStack];
        final tags = rawTags is Iterable
            ? rawTags
                  .map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
            : const <String>[];
        final summary = (d['completionSummary'] ?? '').toString().trim();
        final fullDesc =
            (d[FirebaseConstants.fieldDescription] ?? '').toString().trim();
        final desc = summary.isNotEmpty ? summary : fullDesc;

        String period = '';
        final rawCompleted = d['completedAt'];
        DateTime? completedAt;
        if (rawCompleted is DateTime) {
          completedAt = rawCompleted;
        } else if (rawCompleted != null) {
          try {
            completedAt = (rawCompleted as dynamic).toDate() as DateTime?;
          } catch (_) {
            completedAt = DateTime.tryParse(rawCompleted.toString());
          }
        }
        if (completedAt != null) {
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
          ];
          period =
              'Completed ${months[completedAt.month - 1]} ${completedAt.day}, ${completedAt.year}';
        }

        return PortfolioProjectData(
          projectId: (d['id'] ?? '').toString(),
          badgeText: rawType,
          statusText: statusLabel,
          topIcon: isCompleted
              ? Icons.rocket_launch_outlined
              : Icons.workspaces_outline,
          title: (d[FirebaseConstants.fieldTitle] ?? 'Project').toString(),
          description: fullDesc.isNotEmpty ? fullDesc : desc,
          completionSummary: summary,
          roleText: entry.isOwner ? 'Project Owner' : 'Team Member',
          trailingInfoIcon: Icons.group_outlined,
          trailingInfoText: '$filled ${filled == 1 ? 'member' : 'members'}',
          logoUrl: (d['productLogoUrl'] ?? '').toString().trim(),
          productUrl: (d['productUrl'] ?? '').toString().trim(),
          repoUrl: (d['repoUrl'] ?? '').toString().trim(),
          period: period,
          tags: tags,
          awards: awards,
          isCompleted: isCompleted,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // Fetch all team members who worked on a project (Owner pinned first).
  Future<List<({DeveloperModel developer, String teamRole, String track})>>
  fetchProjectContributors(String projectId) async {
    if (projectId.isEmpty) return const [];
    try {
      final memberDocs = await _firestore.getCollection(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/$projectId/${FirebaseConstants.membersCollection}',
      );
      final contributors =
          <({DeveloperModel developer, String teamRole, String track, int rank})>[];

      for (final m in memberDocs) {
        final uid = (m[FirebaseConstants.fieldUid] ?? m['id'] ?? '').toString();
        if (uid.isEmpty) continue;
        final rawRole = (m['teamRole'] ?? '').toString().toLowerCase();
        final isOwner = rawRole == 'owner' || m[FirebaseConstants.fieldIsOwner] == true;
        final isLeader = rawRole == 'trackleader' || rawRole == 'track_leader';
        final roleLabel = isOwner
            ? 'Owner'
            : isLeader
            ? 'Track Leader'
            : 'Member';
        final track = (m[FirebaseConstants.fieldTrack] ?? '').toString().trim();

        final userDoc = await _firestore.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: uid,
        );
        final dev = userDoc != null
            ? DeveloperModel.fromFirestore({...userDoc, 'id': uid})
            : DeveloperModel(
                id: uid,
                name: (m[FirebaseConstants.fieldName] ?? 'Developer').toString(),
                publicId: m['username']?.toString(),
                role: track.isNotEmpty ? track : 'Contributor',
                level: 'Intermediate',
                skills: const [],
                bio: '',
              );

        contributors.add((
          developer: dev,
          teamRole: roleLabel,
          track: track.isNotEmpty ? track : dev.role,
          rank: isOwner ? 0 : (isLeader ? 1 : 2),
        ));
      }

      contributors.sort((a, b) {
        final cmp = a.rank.compareTo(b.rank);
        if (cmp != 0) return cmp;
        return a.developer.name
            .toLowerCase()
            .compareTo(b.developer.name.toLowerCase());
      });

      return contributors
          .map(
            (e) => (
              developer: e.developer,
              teamRole: e.teamRole,
              track: e.track,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // Real-time stream of discoverable developers (including live online presence).
  Stream<List<DeveloperModel>> watchDevelopers() {
    final uid = _auth.currentUserId;
    return _firestore
        .collectionStream(collectionPath: FirebaseConstants.usersCollection)
        .map(
          (docs) => docs
              .where((d) => (d['id'] ?? d[FirebaseConstants.fieldUid]) != uid)
              .map(DeveloperModel.fromFirestore)
              .toList(),
        );
  }

  // Real-time stream of saved project/developer IDs for the current user.
  Stream<Set<String>> watchSavedIds() {
    final uid = _auth.currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collectionStream(
          collectionPath:
              '${FirebaseConstants.usersCollection}/$uid/${FirebaseConstants.savedCollection}',
        )
        .map((docs) => docs.map((d) => (d['id'] ?? '').toString()).toSet());
  }

  // Real-time stream of project IDs the current user has active requests on.
  Stream<Set<String>> watchAppliedProjectIds() {
    final uid = _auth.currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collectionStream(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldApplicantId, isEqualTo: uid),
        )
        .map(
          (docs) => docs
              .where((d) {
                final status = (d[FirebaseConstants.fieldStatus] ?? 'pending')
                    .toString()
                    .toLowerCase();
                return status == 'pending' || status == 'accepted';
              })
              .map((d) => (d[FirebaseConstants.fieldProjectId] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toSet(),
        );
  }

  // Fetch saved project and developer IDs for current user.
  Future<Set<String>> fetchSavedIds() async {
    final uid = _auth.currentUserId;
    if (uid == null) return const {};
    try {
      final docs = await _firestore.getCollection(
        collectionPath:
            '${FirebaseConstants.usersCollection}/$uid/${FirebaseConstants.savedCollection}',
      );
      return docs.map((d) => d['id'].toString()).toSet();
    } catch (_) {
      return const {};
    }
  }

  // Fetch project IDs the current user has already applied to.
  Future<Set<String>> fetchAppliedProjectIds() async {
    final uid = _auth.currentUserId;
    if (uid == null) return const {};
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.requestsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldApplicantId, isEqualTo: uid),
      );
      return docs
          .map((d) => (d[FirebaseConstants.fieldProjectId] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  // Fetch developer IDs the current user has already invited.
  Future<Set<String>> fetchInvitedDeveloperIds() async {
    final uid = _auth.currentUserId;
    if (uid == null) return const {};
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.invitationsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
      );
      return docs
          .map((d) => (d[FirebaseConstants.fieldInviteeId] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return const {};
    }
  }

  // Toggle saved bookmark in Firestore users/{uid}/saved/{itemId}.
  Future<void> toggleSaved(String itemId, {String kind = 'project'}) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final path =
        '${FirebaseConstants.usersCollection}/$uid/${FirebaseConstants.savedCollection}';
    try {
      final existing = await _firestore.getDocument(
        collectionPath: path,
        docId: itemId,
      );
      if (existing != null) {
        await _firestore.deleteDocument(collectionPath: path, docId: itemId);
      } else {
        await _firestore.setDocument(
          collectionPath: path,
          docId: itemId,
          data: {
            FirebaseConstants.fieldKind: kind,
            FirebaseConstants.fieldSavedAt: _firestore.serverTimestamp,
          },
        );
      }
    } catch (_) {}
  }

  // Submit join request to requests/{projectId}_{applicantId} with ownerId for real-time delivery.
  Future<void> applyToProject(String projectId, {String? projectTitle}) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      final results = await Future.wait([
        _firestore.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: uid,
        ),
        _firestore.getDocument(
          collectionPath: FirebaseConstants.projectsCollection,
          docId: projectId,
        ),
      ]);
      final userDoc = results[0];
      final projectDoc = results[1];
      final ownerId =
          (projectDoc?[FirebaseConstants.fieldOwnerId] ?? '').toString();
      final resolvedTitle = projectTitle ??
          (projectDoc?[FirebaseConstants.fieldTitle] ?? '').toString();
      final rawTrack = (userDoc?[FirebaseConstants.fieldTrack] ?? '')
          .toString()
          .trim();
      final trackLabel = rawTrack.isNotEmpty ? rawTrack : 'Contributor';
      final rawSkills = userDoc?[FirebaseConstants.fieldSkills];
      final snapshot = {
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldName:
            userDoc?[FirebaseConstants.fieldName] ??
            _auth.currentUser?.displayName ??
            'Developer',
        FirebaseConstants.fieldPhotoUrl:
            userDoc?[FirebaseConstants.fieldPhotoUrl] ??
            _auth.currentUser?.photoURL ??
            '',
        FirebaseConstants.fieldPublicId:
            userDoc?['username'] ??
            userDoc?[FirebaseConstants.fieldPublicId] ??
            uid,
        FirebaseConstants.fieldTrack: trackLabel,
        FirebaseConstants.fieldLevel:
            userDoc?[FirebaseConstants.fieldLevel] ??
            UserLevel.intermediate.label,
        FirebaseConstants.fieldSkills:
            rawSkills is Iterable ? rawSkills.toList() : const <String>[],
      };

      await _firestore.setDocument(
        collectionPath: FirebaseConstants.requestsCollection,
        docId: FirebaseConstants.requestDocId(projectId, uid),
        data: {
          FirebaseConstants.fieldProjectId: projectId,
          if (resolvedTitle.isNotEmpty)
            FirebaseConstants.fieldProjectTitle: resolvedTitle,
          if (ownerId.isNotEmpty) FirebaseConstants.fieldOwnerId: ownerId,
          FirebaseConstants.fieldApplicantId: uid,
          FirebaseConstants.fieldApplicantSnapshot: snapshot,
          FirebaseConstants.fieldTrack: trackLabel,
          FirebaseConstants.fieldStatus: RequestStatus.pending.name,
          FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
        },
      );
    } catch (_) {}
  }

  // Withdraw join request from requests/{projectId}_{applicantId}.
  Future<void> cancelApplication(String projectId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      await _firestore.deleteDocument(
        collectionPath: FirebaseConstants.requestsCollection,
        docId: FirebaseConstants.requestDocId(projectId, uid),
      );
    } catch (_) {}
  }

  // Send project invitation to a developer in invitations/{projectId}_{developerId}.
  Future<void> inviteDeveloper({
    required DeveloperModel developer,
    required ProjectModel project,
  }) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.invitationsCollection,
        docId: FirebaseConstants.invitationDocId(project.id, developer.id),
        data: {
          FirebaseConstants.fieldProjectId: project.id,
          FirebaseConstants.fieldProjectTitle: project.title,
          FirebaseConstants.fieldOwnerId: uid,
          FirebaseConstants.fieldInviteeId: developer.id,
          FirebaseConstants.fieldInviteeSnapshot: {
            FirebaseConstants.fieldUid: developer.id,
            FirebaseConstants.fieldName: developer.name,
            FirebaseConstants.fieldPhotoUrl: developer.imageUrl ?? '',
            FirebaseConstants.fieldPublicId: developer.username,
            FirebaseConstants.fieldTrack: developer.role,
            FirebaseConstants.fieldLevel: developer.level,
          },
          FirebaseConstants.fieldTrack: developer.role,
          FirebaseConstants.fieldStatus: InvitationStatus.pending.name,
          FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
        },
      );
    } catch (_) {}
  }
}
