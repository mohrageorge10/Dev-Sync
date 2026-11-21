import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:flutter/material.dart';

// Show auth feedback toast.
void showAuthMessage(
  BuildContext context,
  String message, {
  AppFeedbackType type = AppFeedbackType.info,
}) {
  AppFeedback.show(context, message: message, type: type);
}

// Handle successful authentication and enter the main app shell.
Future<void> onAuthenticated(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: false);
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
}

// Handle guest mode continuation and enter guest discover feed.
Future<void> continueAsGuest(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: true);
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.discoverGuest,
    (_) => false,
  );
}
