import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Modal bottom sheet prompting guest users to log in.
class LoginRequiredSheet extends StatelessWidget {
  const LoginRequiredSheet({super.key, required this.message});

  final String message;

  static Future<void> show(
    BuildContext context, {
    required String message,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LoginRequiredSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            const SizedBox(height: 20),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: c.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text('Authentication Required', style: AppStyles.h3(context)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.body12Secondary(context),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                buttonText: 'Log In to DevSync',
                leadingIcon: Icons.login_rounded,
                isDisabled: false,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.login);
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                buttonText: 'Create Account',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.createAccount);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
