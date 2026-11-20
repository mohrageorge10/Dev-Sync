import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Footer prompt with inline action link.
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
        Text(text, style: AppStyles.body14Secondary(context)),
        const SizedBox(width: 6),
        AppTextButton(onPressed: onTap, buttonText: actionLabel),
      ],
    );
  }
}
