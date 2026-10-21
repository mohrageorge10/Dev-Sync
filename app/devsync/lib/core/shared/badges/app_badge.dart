import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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

  /// Text, dot and border color.
  final Color color;

  final Color backgroundColor;

  /// Small dot before the text (used in purpose badges).
  final bool showDot;

  final bool showBorder;

  /// Optional icon before the text (e.g. the bolt in "89% Match").
  final IconData? icon;

  // ───────────── Ready-made badges (so you don't pick colors by hand) ─────────────

  /// Purpose: LEARNING (blue, dot, border).
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

  /// Purpose: REAL-WORLD (green, dot, border).
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

  /// Status: Open / Accepted (green).
  factory AppBadge.success(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.success, backgroundColor: c.subtle(c.success));
  }

  /// Status: Pending (yellow).
  factory AppBadge.warning(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.warning, backgroundColor: c.subtle(c.warning));
  }

  /// Status: Declined (red).
  factory AppBadge.error(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.error, backgroundColor: c.subtle(c.error));
  }

  /// Status: Full (blue).
  factory AppBadge.info(BuildContext context, String label) {
    final c = context.colors;
    return AppBadge(
        label: label, color: c.primary, backgroundColor: c.subtleBlueSurface);
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}