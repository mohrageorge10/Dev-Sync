import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Top availability badge with share and bookmark actions.
class AvailableHireHeader extends StatelessWidget {
  final VoidCallback? onSharePressed;
  final VoidCallback? onBookmarkPressed;
  final bool isSaved;

  const AvailableHireHeader({
    super.key,
    this.onSharePressed,
    this.onBookmarkPressed,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppBadge(
          label: 'AVAILABLE FOR HIRE',
          color: c.success,
          backgroundColor: c.subtle(c.success),
          showDot: true,
        ),
        Row(
          children: [
            _SquareIconButton(
              icon: Icons.share_outlined,
              color: c.textPrimary,
              onTap: onSharePressed,
            ),
            const SizedBox(width: 6),
            _SquareIconButton(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved ? c.primary : c.textPrimary,
              onTap: onBookmarkPressed,
            ),
          ],
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}