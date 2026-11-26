import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:flutter/material.dart';

// Confirmation dialog before deleting the user's uploaded CV.
Future<bool> showDeleteCvDialog(BuildContext context) async {
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
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: c.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delete CV?',
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
                'Are you sure you want to remove your CV from your profile? You can upload a new PDF anytime.',
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
                      'Delete',
                      icon: Icons.delete_outline_rounded,
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
  return result ?? false;
}
