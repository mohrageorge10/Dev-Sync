import 'dart:typed_data';

import 'package:devsync/core/services/cloudinary/cloudinary_service.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';

// Firestore & Cloudinary persistence layer for the authenticated user's profile.
class ProfileRepository {
  ProfileRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
    required CloudinaryService cloudinaryService,
  }) : _firestore = firestoreService,
       _auth = authService,
       _cloudinary = cloudinaryService;

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;
  final CloudinaryService _cloudinary;

  String? get currentUserId => _auth.currentUserId;
  String? get currentDisplayName => _auth.currentUser?.displayName;
  String? get currentEmail => _auth.currentUser?.email;

  // Load the current user's profile document from users/{uid}.
  Future<Map<String, dynamic>?> fetchProfile() async {
    final uid = _auth.currentUserId;
    if (uid == null) return null;
    try {
      return await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
    } catch (_) {
      return null;
    }
  }

  // Real-time stream of the current user's profile document.
  Stream<Map<String, dynamic>?> watchProfile() {
    final uid = _auth.currentUserId;
    if (uid == null) return const Stream.empty();
    return _firestore.documentStream(
      collectionPath: FirebaseConstants.usersCollection,
      docId: uid,
    );
  }

  // Upload an avatar image to Cloudinary and persist its URL in Firestore.
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uid = _auth.currentUserId;
    final url = await _cloudinary.uploadAvatar(
      bytes: bytes,
      fileName: fileName,
      uid: uid,
    );
    await saveProfile({FirebaseConstants.fieldPhotoUrl: url});
    return url;
  }

  // Upload a CV file to Cloudinary and persist its URL & metadata in Firestore.
  Future<String> uploadCv({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uid = _auth.currentUserId;
    final url = await _cloudinary.uploadCv(
      bytes: bytes,
      fileName: fileName,
      uid: uid,
    );
    await saveProfile({
      FirebaseConstants.fieldCvUrl: url,
      FirebaseConstants.fieldCvFileName: fileName,
      FirebaseConstants.fieldCvUpdatedAt: DateTime.now().toIso8601String(),
    });
    return url;
  }

  // Check whether a username is unused by any other user in users collection.
  Future<bool> isUsernameAvailable(String username) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.length < 3) return false;
    final uid = _auth.currentUserId;
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.usersCollection,
      );
      for (final doc in docs) {
        final docUid = (doc[FirebaseConstants.fieldUid] ?? doc['id'] ?? '')
            .toString();
        if (uid != null && docUid == uid) continue;
        final existing = (doc['username'] ?? '').toString().trim().toLowerCase();
        if (existing == normalized) return false;
        if (existing.isEmpty) {
          final derived = (doc[FirebaseConstants.fieldName] ?? '')
              .toString()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (derived == normalized) return false;
        }
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  // Persist profile changes to users/{uid} with merge semantics.
  Future<void> saveProfile(Map<String, dynamic> data) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    try {
      await _firestore.setDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
        data: {
          FirebaseConstants.fieldUid: uid,
          ...data,
          FirebaseConstants.fieldUpdatedAt: DateTime.now().toIso8601String(),
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Sign out the current user from Firebase Auth.
  Future<void> signOut() => _auth.signOut();
}
