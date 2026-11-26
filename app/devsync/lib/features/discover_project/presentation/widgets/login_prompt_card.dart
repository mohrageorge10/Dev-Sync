import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Guest banner prompting authentication.
class LoginPromptCard extends StatelessWidget {
  const LoginPromptCard({
    super.key,
    this.onLoginPressed,
    this.onCreateAccountPressed,
  });

  final VoidCallback? onLoginPressed;
  final VoidCallback? onCreateAccountPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.backgroundPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: c.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log in for personalized matches',
                      style: AppStyles.title16SemiBold(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Connect your GitHub to see precision match scores tailored to your verified skills.',
                      style: AppStyles.body12Secondary(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AppPrimaryButton(
                buttonText: 'Log In',
                leadingIcon: Icons.login_rounded,
                isDisabled: false,
                onPressed: onLoginPressed ?? () {},
              ),
              const SizedBox(width: 16),
              AppTextButton(
                buttonText: 'Create Account',
                onPressed: onCreateAccountPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}