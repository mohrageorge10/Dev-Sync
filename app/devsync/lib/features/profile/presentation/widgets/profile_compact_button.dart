import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Compact inline action button used in checklist rows and account cards.
class ProfileCompactButton extends StatelessWidget {
  const ProfileCompactButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.filled = false,
    this.color,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = color ?? c.primary;
    final fg = filled ? c.onPrimary : tint;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? tint : tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(icon, size: 13, color: fg),
              ),
            Text(label, style: AppStyles.body11Bold(context, color: fg)),
          ],
        ),
      ),
    );
  }
}
