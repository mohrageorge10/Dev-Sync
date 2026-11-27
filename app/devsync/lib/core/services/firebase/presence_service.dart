import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:flutter/widgets.dart';

// Manages real-time online presence (isOnline + lastSeen) in Firestore users/{uid}.
class PresenceService {
  PresenceService({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
  }) : _firestore = firestoreService,
       _auth = authService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;

  AppLifecycleListener? _lifecycleListener;
  StreamSubscription? _authSub;
  Timer? _heartbeat;
  String? _activeUid;
  bool _started = false;

  // Consider a user online if flagged online and last seen within 5 minutes.
  static bool isRecentlyOnline(bool isOnline, DateTime? lastSeen) {
    if (!isOnline) return false;
    if (lastSeen == null) return true;
    return DateTime.now().difference(lastSeen).inMinutes <= 5;
  }

  // Format human-readable presence text (e.g. "Online", "Active 4m ago").
  static String formatPresence(bool isOnline, DateTime? lastSeen) {
    if (isRecentlyOnline(isOnline, lastSeen)) return 'Online';
    if (lastSeen == null) return 'Offline';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours}h ago';
    if (diff.inDays < 7) return 'Active ${diff.inDays}d ago';
    return 'Offline';
  }

  // Start tracking lifecycle and auth state for the signed-in user.
  void start() {
    if (_started) {
      _setOnline(true);
      return;
    }
    _started = true;
    _activeUid = _auth.currentUserId;
    if (_activeUid != null) {
      _setOnline(true);
      _startHeartbeat();
    }

    _authSub = _auth.authStateChanges.listen((user) {
      final prevUid = _activeUid;
      final nextUid = user?.uid;
      if (prevUid != null && prevUid != nextUid) {
        _writePresence(prevUid, false);
      }
      _activeUid = nextUid;
      if (nextUid != null) {
        _setOnline(true);
        _startHeartbeat();
      } else {
        _heartbeat?.cancel();
      }
    });

    _lifecycleListener = AppLifecycleListener(
      onResume: () => _setOnline(true),
      onPause: () => _setOnline(false),
      onHide: () => _setOnline(false),
      onDetach: () => _setOnline(false),
    );
  }

  // Explicitly mark the current user offline (e.g. right before sign-out).
  Future<void> goOffline() async {
    _heartbeat?.cancel();
    final uid = _activeUid ?? _auth.currentUserId;
    if (uid != null) {
      await _writePresence(uid, false);
    }
  }

  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _setOnline(true),
    );
  }

  Future<void> _setOnline(bool online) async {
    final uid = _activeUid ?? _auth.currentUserId;
    if (uid == null) return;
    await _writePresence(uid, online);
  }

  Future<void> _writePresence(String uid, bool online) async {
    try {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
        data: {
          FirebaseConstants.fieldIsOnline: online,
          FirebaseConstants.fieldLastSeen: FieldValue.serverTimestamp(),
        },
        merge: true,
      );
    } catch (_) {}
  }

  void dispose() {
    _heartbeat?.cancel();
    _authSub?.cancel();
    _lifecycleListener?.dispose();
    _started = false;
  }
}
