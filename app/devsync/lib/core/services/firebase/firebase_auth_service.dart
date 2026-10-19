
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

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    // Google Sign-In v7 on Android needs the *web* client ID, otherwise
    // authenticate() fails. Throws a clear error if it's missing from .env.
    final String? serverClientId =
        defaultTargetPlatform == TargetPlatform.android
            ? ApiKey.googleServerClientId
            : null;

    await googleSignIn.initialize(serverClientId: serverClientId);
    _googleInitialized = true;
  }

  // Sign in with Email & Password
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

  // Sign up with Email & Password
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

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final GoogleSignInAccount googleUser =
        await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final AuthCredential credential =
        GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential result =
        await auth.signInWithCredential(credential);

    return result.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _initializeGoogleSignIn();
    await auth.signOut();
    await googleSignIn.signOut();
  }
}
