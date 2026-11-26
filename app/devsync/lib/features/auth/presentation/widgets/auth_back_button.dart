import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Back button for auth form screens.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 18,
        color: context.colors.textPrimary,
      ),
      onPressed: () => Navigator.maybePop(context),
    );
  }
}
