import 'dart:math';

import 'package:devsync/core/networking/errors/firebase_error_handler.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/auth/data/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Readable authentication error exposed to the UI.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

// Repository handling Firebase authentication and Firestore user profile setup.
class AuthRepository {
  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _auth = authService,
        _firestore = firestoreService;

  final FirebaseAuthService _auth;
  final FirestoreService _firestore;

  static const _noUserMessage = 'Something went wrong. Please try again.';
  static const _profileMessage =
      "We couldn't save your profile. Please check your connection and try again.";

  static const _publicIdAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _publicIdLength = 8;
  static const _publicIdMaxAttempts = 5;

  // Email and password sign-in.
  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final user = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (user == null) throw const AuthException(_noUserMessage);
        return _profileOrSignOut(user);
      });

  // Email and password registration with profile creation.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final user = await _auth.signUpWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (user == null) throw const AuthException(_noUserMessage);

        try {
          await _auth.updateDisplayName(displayName: name);
          return await _loadOrCreateProfile(user, name: name);
        } catch (_) {
          await _rollbackNewUser(user);
          rethrow;
        }
      });

  // Google sign-in; returns null if cancelled by the user.
  Future<UserModel?> signInWithGoogle() async {
    try {
      return await _guard(() async {
        final user = await _auth.signInWithGoogle();
        if (user == null) throw const AuthException(_noUserMessage);
        return _profileOrSignOut(user);
      });
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const AuthException('Google Sign-In failed. Please try again.');
    }
  }

  // Send password reset link.
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  // Sign out current user.
  Future<void> logout() => _guard(() => _auth.signOut());

  // Load existing Firestore profile or create a new one atomically.
  Future<UserModel> _loadOrCreateProfile(User user, {String? name}) async {
    try {
      final email = user.email ?? '';
      final existing = await _firestore.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: user.uid,
      );
      if (existing != null) {
        return UserModel.fromJson(existing, email: email);
      }

      final cleanName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (user.displayName ?? '');

      return await _createProfile(
        UserModel(
          uid: user.uid,
          name: cleanName,
          email: email,
          photoUrl: user.photoURL,
        ),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('AuthRepository: profile load/save failed: $e');
      throw const AuthException(_profileMessage);
    }
  }

  // Create publicIds, users, and userPrivate documents in a single transaction.
  Future<UserModel> _createProfile(UserModel base) async {
    for (var attempt = 0; attempt < _publicIdMaxAttempts; attempt++) {
      final publicId = _generatePublicId();

      final created = await _firestore.runTransaction<bool>((tx) async {
        final publicRef = _firestore.documentReference(
          collectionPath: FirebaseConstants.publicIdsCollection,
          docId: publicId,
        );
        final userRef = _firestore.documentReference(
          collectionPath: FirebaseConstants.usersCollection,
          docId: base.uid,
        );
        final privateRef = _firestore.documentReference(
          collectionPath: FirebaseConstants.userPrivateCollection,
          docId: base.uid,
        );

        final taken = await tx.get(publicRef);
        if (taken.exists) return false;

        final now = _firestore.serverTimestamp;
        tx.set(publicRef, {
          FirebaseConstants.fieldUid: base.uid,
          FirebaseConstants.fieldCreatedAt: now,
        });
        tx.set(userRef, {
          ...base.toUserJson(),
          FirebaseConstants.fieldPublicId: publicId,
          FirebaseConstants.fieldCreatedAt: now,
          FirebaseConstants.fieldUpdatedAt: now,
        });
        tx.set(privateRef, base.toPrivateJson());
        return true;
      });

      if (created) {
        return UserModel(
          uid: base.uid,
          name: base.name,
          email: base.email,
          photoUrl: base.photoUrl,
          publicId: publicId,
        );
      }
    }
    throw const AuthException(_profileMessage);
  }

  String _generatePublicId() {
    final random = Random.secure();
    return List.generate(
      _publicIdLength,
      (_) => _publicIdAlphabet[random.nextInt(_publicIdAlphabet.length)],
    ).join();
  }

  Future<UserModel> _profileOrSignOut(User user) async {
    try {
      return await _loadOrCreateProfile(user);
    } catch (_) {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> _rollbackNewUser(User user) async {
    try {
      await user.delete();
    } catch (_) {
      await _auth.signOut();
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthException(FirebaseErrorHandler.handle(e));
    }
  }
}
