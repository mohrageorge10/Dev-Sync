import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

/// Simple app bar for the AI Match screens: back arrow + title.
class MatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MatchAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      backgroundColor: c.backgroundPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title, style: AppStyles.title16Bold(context)),
    );
  }
}
