import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/auth/presentation/widgets/icon_badge.dart';
import 'package:flutter/material.dart';

// Modal bottom sheet prompting guests to log in or create an account.
Future<void> showLoginRequiredSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.backgroundPrimary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final c = sheetContext.colors;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            const IconBadge(icon: Icons.lock_outline, size: 56, circular: true),
            const SizedBox(height: 16),
            Text('Log in to continue', style: AppStyles.h3(sheetContext)),
            const SizedBox(height: 8),
            Text(
              'Create an account or log in to join projects, save repositories, and message developers.',
              textAlign: TextAlign.center,
              style: AppStyles.body14Secondary(sheetContext),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                buttonText: 'Log In',
                trailingIcon: Icons.arrow_forward,
                isDisabled: false,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, AppRoutes.login);
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                buttonText: 'Create Account',
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, AppRoutes.createAccount);
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                'Not now',
                style: AppStyles.body14Primary(sheetContext),
              ),
            ),
          ],
        ),
      );
    },
  );
}
