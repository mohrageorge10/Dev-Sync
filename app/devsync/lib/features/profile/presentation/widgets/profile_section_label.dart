import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Section heading with optional leading icon and trailing label.
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.trailingColor,
    this.icon,
  });

  final String text;
  final String? trailing;
  final Color? trailingColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(icon, size: 17, color: c.primary),
            ),
          Expanded(child: Text(text, style: AppStyles.body14Bold(context))),
          if (trailing != null)
            Text(
              trailing!,
              style: AppStyles.body12SemiBold(
                context,
                color: trailingColor ?? c.primary,
              ),
            ),
        ],
      ),
    );
  }
}
