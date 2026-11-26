import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// App bar used across auth secondary screens.
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
      shadowColor: AppColors.ambientShadow,
      toolbarHeight: 64,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: c.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title, style: AppStyles.title17SemiBold(context)),
    );
  }
}
