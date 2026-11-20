import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/database/cache.dart';
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

// Handle successful authentication.
Future<void> onAuthenticated(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: false);
  if (!context.mounted) return;
  showAuthMessage(
    context,
    'Signed in successfully.',
    type: AppFeedbackType.success,
  );
}

// Handle guest mode continuation.
Future<void> continueAsGuest(BuildContext context) async {
  await CacheHelper.saveData(key: AppConstants.prefsIsGuest, value: true);
  if (!context.mounted) return;
  showAuthMessage(context, 'Continuing as guest.');
}
