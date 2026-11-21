import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/developers_data.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/data/model/projects_data.dart';

// Unified repository for discovering projects, developers, bookmarks, applications, and invites.
class DiscoverRepository {
  DiscoverRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  }) : _firestore = firestoreService,
       _auth = authService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  // Fetch current user profile summary (name, profile strength, track, and skills).
  Future<
    ({
      String userName,
      double profileStrength,
      String? userTrack,
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

        final rawSkills = doc[FirebaseConstants.fieldSkills];
        final userSkills = <String>[
          if (rawSkills is Iterable)
            for (final s in rawSkills) s.toString(),
        ];

        var filled = 1;
        if ((doc[FirebaseConstants.fieldBio] ?? '').toString().isNotEmpty) {
          filled++;
        }
        if (userSkills.isNotEmpty) filled++;
        if (doc[FirebaseConstants.fieldGithubConnected] == true) filled++;
        if ((doc[FirebaseConstants.fieldCvUrl] ?? '').toString().isNotEmpty) {
          filled++;
        }
        return (
          userName: name,
          profileStrength: (filled / 5).clamp(0.2, 1.0),
          userTrack: userTrack,
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
      userSkills: const <String>[],
    );
  }

  // Current authenticated user ID.
  String? get currentUserId => _auth.currentUserId;

  // Fetch non-draft projects from Firestore with local fallback.
  Future<List<ProjectModel>> fetchProjects() async {
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.projectsCollection,
      );
      final mapped = docs
          .where(
            (d) => d[FirebaseConstants.fieldStatus] != ProjectStatus.draft.name,
          )
          .map(ProjectModel.fromFirestore)
          .toList();
      if (mapped.isNotEmpty) return mapped;
    } catch (_) {}
    return projectsData;
  }

  // Fetch developers from Firestore with local fallback.
  Future<List<DeveloperModel>> fetchDevelopers() async {
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.usersCollection,
      );
      final uid = _auth.currentUserId;
      final mapped = docs
          .where((d) => (d['id'] ?? d[FirebaseConstants.fieldUid]) != uid)
          .map(DeveloperModel.fromFirestore)
          .toList();
      if (mapped.isNotEmpty) return mapped;
    } catch (_) {}
    return developersData;
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

  // Submit join request to requests/{projectId}_{applicantId}.
  Future<void> applyToProject(String projectId, {String? projectTitle}) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      final userDoc = await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      final track = UserTrackX.fromName(
        userDoc?[FirebaseConstants.fieldTrack]?.toString(),
      );
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
            userDoc?[FirebaseConstants.fieldPublicId] ?? uid,
        FirebaseConstants.fieldTrack: track.name,
        FirebaseConstants.fieldLevel:
            userDoc?[FirebaseConstants.fieldLevel] ??
            UserLevel.intermediate.name,
      };

      await _firestore.setDocument(
        collectionPath: FirebaseConstants.requestsCollection,
        docId: FirebaseConstants.requestDocId(projectId, uid),
        data: {
          FirebaseConstants.fieldProjectId: projectId,
          FirebaseConstants.fieldProjectTitle: ?projectTitle,
          FirebaseConstants.fieldApplicantId: uid,
          FirebaseConstants.fieldApplicantSnapshot: snapshot,
          FirebaseConstants.fieldTrack: track.name,
          FirebaseConstants.fieldStatus: RequestStatus.pending.name,
          FirebaseConstants.fieldCreatedAt: _firestore.serverTimestamp,
        },
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
