import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:flutter/material.dart';

// Confirmation dialog before disconnecting Behance from the user's profile.
Future<bool> showDisconnectBehanceDialog(
  BuildContext context, {
  int shotsCount = 0,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      final c = dialogCtx.colors;
      return Dialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: c.subtle(c.error),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.link_off_rounded,
                      size: 20,
                      color: c.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Disconnect Behance?',
                      style: AppStyles.title17Bold(dialogCtx),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(dialogCtx, false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                shotsCount > 0
                    ? 'Your Behance link, design tools, and $shotsCount featured case ${shotsCount == 1 ? 'study' : 'studies'} will be removed from your profile.'
                    : 'Your Behance portfolio link and design tools will be removed from your profile.',
                style: AppStyles.body13Secondary(dialogCtx),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ProfileSoftButton(
                      'Cancel',
                      onPressed: () => Navigator.pop(dialogCtx, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ProfilePrimaryButton(
                      'Disconnect',
                      icon: Icons.link_off_rounded,
                      color: c.error,
                      onPressed: () => Navigator.pop(dialogCtx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result == true;
}
