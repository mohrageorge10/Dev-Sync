import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Selectable skill chip.
class AppSkillChip extends StatelessWidget {
  const AppSkillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: AppAnimations.easeOut,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? c.subtleBlueSurface : c.surface,
          border: Border.all(color: selected ? c.primary : c.border),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 16, color: c.primary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: selected
                  ? AppStyles.label14SemiBold(context, color: c.primary)
                  : AppStyles.body13Primary(context),
            ),
          ],
        ),
      ),
    );
  }
}