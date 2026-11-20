import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// AppBar used by Forgot Password and Check Inbox screens.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      backgroundColor: c.backgroundPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black12,
      toolbarHeight: 64,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: c.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
    );
  }
}
