import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/project_firestore_mapper.dart';
import 'package:devsync/features/create_project/data/model/publish_result.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';

abstract class ProjectRepository {
  Future<String> saveDraft(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  });

  Future<PublishResult> publish(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  });
}

// Firestore project repository.
class FirestoreProjectRepository implements ProjectRepository {
  FirestoreProjectRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
    required BuildersRepository buildersRepository,
  })  : _firestore = firestoreService,
        _auth = authService,
        _builders = buildersRepository;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;
  final BuildersRepository _builders;

  // Fetch owner profile snapshot from Firestore.
  Future<Map<String, dynamic>> _ownerSnapshot(
    String uid,
    UserTrack fallbackTrack,
  ) async {
    try {
      final doc = await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      if (doc != null) {
        return {
          FirebaseConstants.fieldUid: uid,
          FirebaseConstants.fieldName:
              doc[FirebaseConstants.fieldName] ?? 'Project Owner',
          FirebaseConstants.fieldPhotoUrl:
              doc[FirebaseConstants.fieldPhotoUrl] ?? '',
          FirebaseConstants.fieldPublicId:
              doc[FirebaseConstants.fieldPublicId] ?? uid,
          FirebaseConstants.fieldTrack:
              doc[FirebaseConstants.fieldTrack] ?? fallbackTrack.name,
          FirebaseConstants.fieldLevel:
              doc[FirebaseConstants.fieldLevel] ?? UserLevel.intermediate.name,
        };
      }
    } catch (_) {}

    final u = _auth.currentUser;
    return {
      FirebaseConstants.fieldUid: uid,
      FirebaseConstants.fieldName: u?.displayName ?? 'Project Owner',
      FirebaseConstants.fieldPhotoUrl: u?.photoURL ?? '',
      FirebaseConstants.fieldPublicId: u?.email?.split('@').first ?? uid,
      FirebaseConstants.fieldTrack: fallbackTrack.name,
      FirebaseConstants.fieldLevel: UserLevel.intermediate.name,
    };
  }

  // Create or update draft document.
  @override
  Future<String> saveDraft(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  }) async {
    final ownerId = _auth.currentUserId;
    if (ownerId == null) {
      await Future.delayed(const Duration(milliseconds: 250));
      return existingProjectId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
    }

    final snapshot = await _ownerSnapshot(ownerId, draft.ownerTrack);
    final data = {
      ...ProjectFirestoreMapper.projectData(
        draft: draft,
        tracks: tracks,
        status: ProjectStatus.draft,
        ownerId: ownerId,
        ownerSnapshot: snapshot,
      ),
      if (existingProjectId == null)
        FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
      FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
    };

    if (existingProjectId != null) {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: existingProjectId,
        data: data,
      );
      return existingProjectId;
    }

    return _firestore.addDocument(
      collectionPath: FirebaseConstants.projectsCollection,
      data: data,
    );
  }

  // Publish project, team, owner member, and invitations atomically.
  @override
  Future<PublishResult> publish(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  }) async {
    var projectId =
        existingProjectId ?? 'prj_${DateTime.now().millisecondsSinceEpoch}';
    final ownerId = _auth.currentUserId;

    if (ownerId != null) {
      final snapshot = await _ownerSnapshot(ownerId, draft.ownerTrack);
      final projectRef = existingProjectId != null
          ? _firestore.documentReference(
              collectionPath: FirebaseConstants.projectsCollection,
              docId: existingProjectId,
            )
          : _firestore
              .collectionReference(FirebaseConstants.projectsCollection)
              .doc();
      projectId = projectRef.id;

      final teamRef = _firestore.documentReference(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: projectId,
      );
      final memberRef = teamRef
          .collection(FirebaseConstants.membersCollection)
          .doc(ownerId);
      final invites = ProjectFirestoreMapper.invitations(
        projectId: projectId,
        draft: draft,
        tracks: tracks,
        ownerId: ownerId,
        ownerSnapshot: snapshot,
      );

      await _firestore.runBatch((batch) {
        batch.set(projectRef, {
          ...ProjectFirestoreMapper.projectData(
            draft: draft,
            tracks: tracks,
            status: ProjectStatus.open,
            ownerId: ownerId,
            ownerSnapshot: snapshot,
          ),
          FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
          FirebaseConstants.fieldPublishedAt: _firestore.serverTimestamp,
        });
        batch.set(teamRef, {
          ...ProjectFirestoreMapper.teamData(
            projectId: projectId,
            draft: draft,
            ownerId: ownerId,
          ),
          FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: _firestore.serverTimestamp,
        });
        batch.set(memberRef, {
          ...ProjectFirestoreMapper.ownerMemberData(
            draft: draft,
            ownerId: ownerId,
            ownerSnapshot: snapshot,
          ),
          FirebaseConstants.fieldJoinedAt: _firestore.serverTimestamp,
        });
        for (final inv in invites) {
          batch.set(
            _firestore.documentReference(
              collectionPath: FirebaseConstants.invitationsCollection,
              docId: inv.docId,
            ),
            {
              ...inv.data,
              FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
            },
          );
        }
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return _buildPublishResult(projectId, _builders.pool, tracks);
  }
}

// Local mock project repository.
class MockProjectRepository implements ProjectRepository {
  MockProjectRepository(this._builders);
  final BuildersRepository _builders;

  @override
  Future<String> saveDraft(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return existingProjectId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<PublishResult> publish(
    ProjectDraft draft,
    List<TeamTrack> tracks, {
    String? existingProjectId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final id =
        existingProjectId ?? 'prj_${DateTime.now().millisecondsSinceEpoch}';
    return _buildPublishResult(id, _builders.pool, tracks);
  }
}

// Build publish summary result.
PublishResult _buildPublishResult(
  String projectId,
  List<DevBuilder> pool,
  List<TeamTrack> tracks,
) {
  final open = tracks.where((t) => t.openSpots > 0).toList()
    ..sort((a, b) => b.openSpots.compareTo(a.openSpots));
  final urgent = open.firstOrNull;
  final matched = pool
      .where((b) =>
          b.availableNow &&
          tracks.any((t) =>
              t.definition.track == b.track || b.skills.any(t.skills.contains)))
      .length;

  return PublishResult(
    projectId: projectId,
    matchedDevelopers: matched,
    urgentTrackName: urgent?.definition.name,
    expertise: urgent == null
        ? const []
        : (urgent.skills.isNotEmpty
                ? urgent.skills.toList()
                : urgent.definition.skills)
            .take(2)
            .toList(),
  );
}
