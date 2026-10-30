import 'package:devsync/core/networking/api/end_points.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : auth = firebaseAuth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  bool _googleInitialized = false;

  // ================= Getters =================

  User? get currentUser => auth.currentUser;

  String? get currentUserId => auth.currentUser?.uid;

  bool get isSignedIn => auth.currentUser != null;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Stream<User?> get userChanges => auth.userChanges();

  // ================= Google Sign-In Initialization =================

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    final String? serverClientId =
        defaultTargetPlatform == TargetPlatform.android
            ? ApiKey.googleServerClientId
            : null;

    await googleSignIn.initialize(
      serverClientId: serverClientId,
    );

    _googleInitialized = true;
  }

  // ================= Email & Password Authentication =================

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
        await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
        await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // ================= Google Sign-In =================

  Future<User?> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final GoogleSignInAccount googleUser =
        await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google Sign-In did not return an ID token.',
      );
    }

    final AuthCredential credential =
        GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final UserCredential result =
        await auth.signInWithCredential(credential);

    return result.user;
  }

  // ================= Password Management =================

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    await auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    final User? user = currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user was found.',
      );
    }

    await user.updatePassword(newPassword);
  }

  // ================= Email Verification =================

  Future<void> sendEmailVerification() async {
    final User? user = currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No authenticated user was found.',
      );
    }

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // ================= User Profile Management =================

  Future<void> reloadUser() async {
    await auth.currentUser?.reload();
  }

  Future<void> updateDisplayName({
    required String displayName,
  }) async {
    await auth.currentUser?.updateDisplayName(
      displayName.trim(),
    );
  }

  Future<void> updatePhotoUrl({
    required String photoUrl,
  }) async {
    await auth.currentUser?.updatePhotoURL(photoUrl);
  }

  // ================= Sign Out =================

  Future<void> signOut() async {
    await auth.signOut();

    if (_googleInitialized) {
      await googleSignIn.signOut();
    }
  }
}