import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// "Already have an account?  Log In" style footer.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
        ),
        const SizedBox(width: 6),
        AppTextButton(onPressed: onTap, buttonText: actionLabel),
      ],
    );
  }
}
