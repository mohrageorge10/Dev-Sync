import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Reusable top app bar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.showActions = true,
    this.onNotificationTap,
    this.extraActions = const [],
  });

  final String title;
  final Widget? leading;
  final bool showActions;
  final VoidCallback? onNotificationTap;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      backgroundColor: c.backgroundPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: leading == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: leading,
            ),
      titleSpacing: 8,
      title: Text(title, style: AppStyles.title16Bold(context)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: c.border),
      ),
      actions: [
        ...extraActions,
        if (showActions)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: onNotificationTap ?? () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: c.textPrimary,
                size: 22,
              ),
            ),
          ),
      ],
    );
  }
}
