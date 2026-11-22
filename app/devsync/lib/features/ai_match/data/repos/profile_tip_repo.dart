import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';

/// What the Match History banner needs to know about the user's profile.
class ProfileTipInfo {
  const ProfileTipInfo({
    required this.signedIn,
    this.calibration,
    this.dismissed = false,
  });

  final bool signedIn;

  /// How complete the profile is, 0-100 (null = could not be read).
  final int? calibration;

  /// The user pressed "Dismiss" recently.
  final bool dismissed;
}

abstract class ProfileTipRepo {
  Future<ProfileTipInfo> load();

  /// Remembers that the user dismissed the banner.
  Future<void> dismiss();
}

// ===================== Profile calibration =====================

bool _filled(Object? v) {
  if (v is String) return v.trim().isNotEmpty;
  if (v is Iterable) return v.isNotEmpty;
  if (v is Map) return v.isNotEmpty;
  return false;
}

/// How complete a `users/{uid}` document is, from 0 to 100.
/// The weights add up to 100: change them here if the team wants another mix.
///   track 15 | level 5 | languages 20 | skills 15 | GitHub 15
///   bio 10 | goal 5 | CV or a link 10 | interests 5
int profileCalibration(Map<String, dynamic> user) {
  var score = 0;
  if (_filled(user[FirebaseConstants.fieldTrack])) score += 15;
  if (_filled(user[FirebaseConstants.fieldLevel])) score += 5;
  if (_filled(user[FirebaseConstants.fieldLanguages])) score += 20;
  if (_filled(user[FirebaseConstants.fieldSkills])) score += 15;
  if (user[FirebaseConstants.fieldGithubConnected] == true) score += 15;
  if (_filled(user[FirebaseConstants.fieldBio])) score += 10;
  if (_filled(user[FirebaseConstants.fieldGoalText])) score += 5;
  final hasCvOrLink = [
    FirebaseConstants.fieldCvUrl,
    FirebaseConstants.fieldPortfolioUrl,
    FirebaseConstants.fieldLinkedinUrl,
    FirebaseConstants.fieldBehanceUrl,
  ].any((key) => _filled(user[key]));
  if (hasCvOrLink) score += 10;
  if (_filled(user[FirebaseConstants.fieldInterests])) score += 5;
  return score;
}

// ===================== Firestore =====================

/// `users/{uid}` -> calibration, `userPrivate/{uid}.bannerDismissedAt`
/// -> the banner stays hidden for [dismissCooldown] after "Dismiss".
class FirestoreProfileTipRepo implements ProfileTipRepo {
  FirestoreProfileTipRepo({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  })  : _firestore = firestoreService,
        _auth = authService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  static const _netTimeout = Duration(seconds: 10);
  static const dismissCooldown = Duration(days: 7);

  @override
  Future<ProfileTipInfo> load() async {
    final uid = _auth.currentUserId;
    if (uid == null) return const ProfileTipInfo(signedIn: false);
    try {
      final docs = await Future.wait<Map<String, dynamic>?>([
        _firestore.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: uid,
        ),
        _firestore.getDocument(
          collectionPath: FirebaseConstants.userPrivateCollection,
          docId: uid,
        ),
      ]).timeout(_netTimeout);

      final dismissedAt = docs[1]?[FirebaseConstants.fieldBannerDismissedAt];
      final dismissed = dismissedAt is Timestamp &&
          DateTime.now().difference(dismissedAt.toDate()) < dismissCooldown;

      return ProfileTipInfo(
        signedIn: true,
        calibration: profileCalibration(docs[0] ?? const {}),
        dismissed: dismissed,
      );
    } catch (_) {
      // Profile not readable: no made-up number, the banner stays hidden.
      return const ProfileTipInfo(signedIn: true);
    }
  }

  @override
  Future<void> dismiss() async {
    final uid = _auth.currentUserId;
    if (uid == null) return; // signed out: hidden for this visit only
    try {
      await _firestore
          .setDocument(
            collectionPath: FirebaseConstants.userPrivateCollection,
            docId: uid,
            data: {
              FirebaseConstants.fieldBannerDismissedAt:
                  _firestore.serverTimestamp,
            },
          )
          .timeout(_netTimeout);
    } catch (_) {
      // Best effort: the banner is already hidden on screen.
    }
  }
}

// ===================== Sample data (previews) =====================

class MockProfileTipRepo implements ProfileTipRepo {
  @override
  Future<ProfileTipInfo> load() async =>
      const ProfileTipInfo(signedIn: true, calibration: 68);

  @override
  Future<void> dismiss() async {}
}
