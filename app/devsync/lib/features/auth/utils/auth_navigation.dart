import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/database/cache.dart';
import 'package:flutter/material.dart';

void showAuthMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Called after a successful login / sign up / Google sign in.
Future<void> onAuthenticated(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: false);
  if (!context.mounted) return;

  // TODO(team): go to the real destination (home / onboarding) here,
  // e.g. Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  showAuthMessage(context, 'Signed in successfully');
}

/// Called from "Continue as Guest".
Future<void> continueAsGuest(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: true);
  if (!context.mounted) return;

  // TODO(team): go to the guest home here (same destination as above).
  showAuthMessage(context, 'Continuing as guest');
}
