import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/data/models/match_feedback.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';

abstract class MatchRepo {
  /// Matches of the signed-in user, best score first.
  Future<List<MatchModel>> getMatches();

  Future<void> submitFeedback(MatchFeedback feedback);

  // ---- Project actions (Why This Fits screen) ----

  /// Is this project in the user's saved list? (false when signed out)
  Future<bool> isSaved(String projectId);

  /// Saves / removes the project. Throws [MatchActionException].
  Future<void> setSaved(MatchModel match, bool saved);

  /// Status of the user's join request for this project (null = none yet).
  Future<RequestStatus?> getJoinRequestStatus(String projectId);

  /// Sends a join request. Throws [MatchActionException].
  Future<void> requestToJoin(MatchModel match, {String pitch = ''});
}

enum MatchActionError {
  notSignedIn,
  projectNotFound,
  ownProject,
  projectClosed,
  alreadyRequested,
}

/// A known reason why a project action could not be done.
class MatchActionException implements Exception {
  const MatchActionException(this.error);

  final MatchActionError error;
}

// Firestore repo with mock fallback (same pattern as BuildersRepository).
class FirestoreMatchRepo implements MatchRepo {
  FirestoreMatchRepo({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
    MatchRepo? fallback,
    bool sampleDataFallback = false,
  })  : _firestore = firestoreService,
        _auth = authService,
        _fallback = fallback ?? MockMatchRepo(),
        _sampleDataFallback = sampleDataFallback;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;
  final MatchRepo _fallback;

  /// true = a signed-in user with no matches (or when Firestore fails) sees
  /// the sample projects. false = the real empty / error screen.
  final bool _sampleDataFallback;

  /// Firestore waits forever when offline; fail after this instead.
  static const _netTimeout = Duration(seconds: 10);

  @override
  Future<List<MatchModel>> getMatches() async {
    final uid = _auth.currentUserId;
    // Signed out: sample projects, as a preview of the feature.
    if (uid == null) return _fallback.getMatches();
    try {
      final docs = await _firestore.getCollection(
        collectionPath: '${FirebaseConstants.matchesCollection}/$uid/'
            '${FirebaseConstants.matchItemsCollection}',
        queryBuilder: (q) =>
            q.orderBy(FirebaseConstants.fieldScore, descending: true),
      ).timeout(_netTimeout);
      final loaded = docs.map(MatchModel.fromFirestore).toList();
      if (loaded.isNotEmpty || !_sampleDataFallback) return loaded;
    } catch (_) {
      // Real error screen ("Try again") unless sample data is turned on.
      if (!_sampleDataFallback) rethrow;
    }
    return _fallback.getMatches();
  }

  @override
  Future<void> submitFeedback(MatchFeedback feedback) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await _firestore.addDocument(
      collectionPath: FirebaseConstants.feedbackCollection,
      data: {
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldProjectId: feedback.projectId,
        FirebaseConstants.fieldKind: feedback.kind.name,
        FirebaseConstants.fieldHelpful: feedback.helpful,
        FirebaseConstants.fieldClarity: feedback.clarity,
        // Check the exact shape of `reason` / `comment` in docs/schema.md.
        FirebaseConstants.fieldReason: feedback.reasons.join(', '),
        'comment': feedback.comment,
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      },
    ).timeout(_netTimeout);
  }

  // ---------------- Project actions ----------------

  String _savedPath(String uid) => '${FirebaseConstants.usersCollection}/$uid/'
      '${FirebaseConstants.savedCollection}'; // CHECK with docs/schema.md

  String _requireUid() {
    final uid = _auth.currentUserId;
    if (uid == null) {
      throw const MatchActionException(MatchActionError.notSignedIn);
    }
    return uid;
  }

  @override
  Future<bool> isSaved(String projectId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return false;
    final doc = await _firestore.getDocument(
      collectionPath: _savedPath(uid),
      docId: projectId,
    ).timeout(_netTimeout);
    return doc != null;
  }

  @override
  Future<void> setSaved(MatchModel match, bool saved) async {
    final uid = _requireUid();
    if (saved) {
      await _firestore.setDocument(
        collectionPath: _savedPath(uid),
        docId: match.projectId,
        data: {
          FirebaseConstants.fieldProjectId: match.projectId,
          FirebaseConstants.fieldProjectTitle: match.projectTitle,
          FirebaseConstants.fieldSavedAt: FieldValue.serverTimestamp(),
        },
      ).timeout(_netTimeout);
    } else {
      await _firestore.deleteDocument(
        collectionPath: _savedPath(uid),
        docId: match.projectId,
      ).timeout(_netTimeout);
    }
  }

  @override
  Future<RequestStatus?> getJoinRequestStatus(String projectId) async {
    final uid = _auth.currentUserId;
    if (uid == null) return null;
    final doc = await _firestore.getDocument(
      collectionPath: FirebaseConstants.requestsCollection,
      docId: FirebaseConstants.requestDocId(projectId, uid),
    ).timeout(_netTimeout);
    if (doc == null) return null;
    final name = doc[FirebaseConstants.fieldStatus];
    for (final s in RequestStatus.values) {
      if (s.name == name) return s;
    }
    return RequestStatus.pending;
  }

  @override
  Future<void> requestToJoin(MatchModel match, {String pitch = ''}) async {
    final uid = _requireUid();
    final docId = FirebaseConstants.requestDocId(match.projectId, uid);

    // One request per project and user (the doc id is projectId_uid).
    final existing = await _firestore.getDocument(
      collectionPath: FirebaseConstants.requestsCollection,
      docId: docId,
    ).timeout(_netTimeout);
    if (existing != null) {
      throw const MatchActionException(MatchActionError.alreadyRequested);
    }

    final project = await _firestore.getDocument(
      collectionPath: FirebaseConstants.projectsCollection,
      docId: match.projectId,
    ).timeout(_netTimeout);
    if (project == null) {
      throw const MatchActionException(MatchActionError.projectNotFound);
    }
    final ownerId = (project[FirebaseConstants.fieldOwnerId] ?? '').toString();
    if (ownerId == uid) {
      throw const MatchActionException(MatchActionError.ownProject);
    }
    final status = project[FirebaseConstants.fieldStatus]?.toString();
    if (status != null && status != ProjectStatus.open.name) {
      throw const MatchActionException(MatchActionError.projectClosed);
    }

    final me = await _firestore.getDocument(
      collectionPath: FirebaseConstants.usersCollection,
      docId: uid,
    ).timeout(_netTimeout);
    await _firestore.setDocument(
      collectionPath: FirebaseConstants.requestsCollection,
      docId: docId,
      merge: false,
      // CHECK the field names with docs/schema.md.
      data: {
        FirebaseConstants.fieldProjectId: match.projectId,
        FirebaseConstants.fieldProjectTitle: match.projectTitle,
        FirebaseConstants.fieldOwnerId: ownerId,
        FirebaseConstants.fieldApplicantId: uid,
        FirebaseConstants.fieldPitch: pitch,
        FirebaseConstants.fieldApplicantSnapshot: {
          FirebaseConstants.fieldName: me?[FirebaseConstants.fieldName] ??
              _auth.currentUser?.displayName ??
              '',
          FirebaseConstants.fieldPhotoUrl:
              me?[FirebaseConstants.fieldPhotoUrl] ?? '',
          FirebaseConstants.fieldTrack: me?[FirebaseConstants.fieldTrack] ?? '',
          FirebaseConstants.fieldLevel: me?[FirebaseConstants.fieldLevel] ?? '',
        },
        FirebaseConstants.fieldStatus: RequestStatus.pending.name,
        FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
      },
    ).timeout(_netTimeout);
  }
}

// Local sample data (used when Firestore is empty or offline).
class MockMatchRepo implements MatchRepo {
  @override
  Future<List<MatchModel>> getMatches() async => [
        MatchModel(
          projectId: 'p1',
          projectTitle: 'EcoTrack Mobile: Carbon Analytics for IoT arrays',
          projectDescription: 'Track and reduce your carbon footprint.',
          purpose: ProjectPurpose.real,
          score: 92,
          leadMaintainer: 'Alex Rivera (@rivera-dev)',
          sprintLabel: 'Sprint Cycle 14',
          matchedSkills: const [
            'Flutter',
            'Dart',
            'REST APIs',
            'Git & GitHub Workflows',
          ],
          missingSkills: const ['Sensor Telemetry', 'Bluetooth Low Energy (BLE)'],
          complementarySkills: const [
            'Riverpod State Management',
            'Offline Storage',
            'Async / Await',
          ],
          learnPoints: const [
            'Hardware sensor integration with low-energy Bluetooth (BLE) '
                'peripheral beacons.',
            'High-volume timeseries data parsing and query indexing in '
                'client-side SQLite.',
            'Collaborative agile workflows and pull request reviews in a '
                'production open-source codebase.',
          ],
          skillDetails: const [
            SkillDetail(
              skill: 'Flutter',
              level: 'Intermediate',
              note: 'Verified from 14 commits in personal repositories',
            ),
            SkillDetail(
              skill: 'Dart',
              level: 'Intermediate',
              note: 'Matched directly to target repository language',
            ),
            SkillDetail(
              skill: 'REST APIs',
              level: 'Architecture',
              note: 'Experienced with serialization & state sync patterns',
            ),
            SkillDetail(
              skill: 'Git & GitHub Workflows',
              level: 'Collaborative',
              note: 'Track record of clean PR branches and squash merges',
            ),
          ],
          learningTips: const [
            LearningTip(
              skill: 'Sensor Telemetry & Time-series Data',
              tip: 'Practice parsing and batching time-series sensor data.',
              whyItMatters:
                  'Used for real-time carbon sensor tracking in background '
                  'processes.',
              whatToLearn:
                  'Mobile background streams and buffering patterns.',
              firstStep: "Review the project's `/lib/services/telemetry` docs "
                  'and open issues tagged #good-first-issue.',
            ),
            LearningTip(
              skill: 'Bluetooth Low Energy (BLE)',
              tip: 'Connect to a BLE beacon with a sample Flutter app.',
              whyItMatters:
                  'Syncing external hardware monitors and wearable telemetry.',
              whatToLearn: '`flutter_reactive_ble` packet handling.',
              firstStep:
                  'Check the sample BLE scanner module in the repository '
                  'sandbox branch.',
            ),
          ],
          highlights: const [
            MatchHighlight(
              title: 'Peer review from Alex Rivera',
              subtitle: 'Senior Staff Mobile Engineer (Maintainer)',
            ),
            MatchHighlight(
              title: 'Real-world hardware communication',
              subtitle: 'Debug raw asynchronous byte streams with hardware '
                  'testing units.',
            ),
            MatchHighlight(
              title: 'High-throughput data handling',
              subtitle: 'First-hand experience handling 10k+ daily sensor '
                  'readings smoothly.',
            ),
          ],
          matchedTrack: 'mobile',
          explanation:
              'This team is actively building offline caching and sensor '
              'telemetry sync in Flutter. Your background in mobile apps and '
              'intermediate Dart makes you an ideal contributor to take '
              'ownership of the background sync service, while expanding '
              'your knowledge of environmental telemetry.',
          source: MatchSource.llm,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        MatchModel(
          projectId: 'p2',
          projectTitle: 'DevMetrics CLI: Git Telemetry & CI Insights',
          projectDescription: 'Command line tool for developer metrics.',
          purpose: ProjectPurpose.learning,
          score: 86,
          matchedSkills: const ['Python', 'CLI', 'Git APIs'],
          missingSkills: const ['CI/CD'],
          complementarySkills: const ['Dart'],
          matchedTrack: 'backend',
          explanation:
              'Great for Python tooling and hands-on command-line automation.',
          source: MatchSource.cached,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        MatchModel(
          projectId: 'p3',
          projectTitle: 'NeuroFlow Engine: Mobile Neural On-Device Runtime',
          projectDescription: 'On-device neural inference runtime.',
          purpose: ProjectPurpose.real,
          score: 78,
          matchedSkills: const ['Python', 'TensorFlow Lite', 'Dart'],
          missingSkills: const ['Model Quantization'],
          matchedTrack: 'ai',
          explanation: 'Good stretch opportunity for TensorFlow Lite '
              'integration and cross-platform inference.',
          source: MatchSource.llm,
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];

  @override
  Future<void> submitFeedback(MatchFeedback feedback) async {}

  // In-memory actions (preview / offline).
  final Set<String> _saved = {};
  final Map<String, RequestStatus> _requests = {};

  @override
  Future<bool> isSaved(String projectId) async => _saved.contains(projectId);

  @override
  Future<void> setSaved(MatchModel match, bool saved) async {
    if (saved) {
      _saved.add(match.projectId);
    } else {
      _saved.remove(match.projectId);
    }
  }

  @override
  Future<RequestStatus?> getJoinRequestStatus(String projectId) async =>
      _requests[projectId];

  @override
  Future<void> requestToJoin(MatchModel match, {String pitch = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _requests[match.projectId] = RequestStatus.pending;
  }
}
