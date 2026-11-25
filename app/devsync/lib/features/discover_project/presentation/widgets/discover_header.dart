import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Discover search screen header with match mode badge.
class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({
    super.key,
    this.title = 'Discover',
    this.subtitle,
    required this.badgeText,
    this.showDot = true,
    this.onBadgePressed,
  });

  final String title;
  final String? subtitle;
  final String badgeText;
  final bool showDot;
  final VoidCallback? onBadgePressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppStyles.h20(context)),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Text(subtitle!, style: AppStyles.body13Secondary(context)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onBadgePressed,
          child: AppBadge(
            label: badgeText,
            color: c.primary,
            backgroundColor: c.subtleBlueSurface,
            showDot: showDot,
          ),
        ),
      ],
    );
  }
}