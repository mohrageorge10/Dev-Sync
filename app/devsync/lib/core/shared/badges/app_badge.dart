import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Pill badge for purpose and status indicators.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.showDot = false,
    this.showBorder = false,
    this.icon,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final bool showDot;
  final bool showBorder;
  final IconData? icon;

  // Learning purpose badge.
  factory AppBadge.learning(BuildContext context) {
    final c = context.colors;
    return AppBadge(
      label: 'LEARNING',
      color: c.primary,
      backgroundColor: c.subtleBlueSurface,
      showDot: true,
      showBorder: true,
    );
  }

  // Real-world purpose badge.
  factory AppBadge.realWorld(BuildContext context) {
    final c = context.colors;
    return AppBadge(
      label: 'REAL-WORLD',
      color: c.success,
      backgroundColor: c.subtle(c.success),
      showDot: true,
      showBorder: true,
    );
  }

  // Success status badge.
  factory AppBadge.success(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.success, backgroundColor: c.subtle(c.success));
  }

  // Warning status badge.
  factory AppBadge.warning(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.warning, backgroundColor: c.subtle(c.warning));
  }

  // Error status badge.
  factory AppBadge.error(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.error, backgroundColor: c.subtle(c.error));
  }

  // Info status badge.
  factory AppBadge.info(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.primary, backgroundColor: c.subtleBlueSurface);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelText = Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.label14SemiBold(context, color: color),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(9999),
            border: showBorder ? Border.all(color: color) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
              ],
              if (constraints.hasBoundedWidth)
                Flexible(child: labelText)
              else
                labelText,
            ],
          ),
        );
      },
    );
  }
}