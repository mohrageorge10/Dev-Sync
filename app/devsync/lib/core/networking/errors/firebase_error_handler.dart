import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract final class FirebaseErrorHandler {
  // ================= Main Error Handler =================

  static String handle(Object error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }

    if (error is FirebaseException) {
      return _handleFirebaseError(error);
    }

    return 'Something went wrong. Please try again.';
  }

  // ================= Authentication Errors =================

  static String _handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'The email address is invalid.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';

      case 'google-sign-in-failed':
        return 'Google Sign-In failed. Please try again.';

      case 'no-current-user':
        return 'No authenticated user was found.';

      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';

      default:
        return error.message ?? 'Authentication failed.';
    }
  }

  // ================= Firebase Errors =================

  static String _handleFirebaseError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';

      case 'not-found':
        return 'The requested document was not found.';

      case 'already-exists':
        return 'This document already exists.';

      case 'unavailable':
        return 'The service is temporarily unavailable.';

      case 'deadline-exceeded':
        return 'The request took too long. Please try again.';

      case 'cancelled':
        return 'The operation was cancelled.';

      case 'resource-exhausted':
        return 'The service limit has been reached.';

      case 'unauthenticated':
        return 'Please sign in to continue.';

      case 'failed-precondition':
        return 'The operation cannot be completed in the current state.';

      case 'invalid-argument':
        return 'Invalid data was provided.';

      default:
        return error.message ?? 'A Firebase error occurred.';
    }
  }
}