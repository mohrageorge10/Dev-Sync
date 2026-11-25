import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Visual identity metadata for each developer experience level.
class ExperienceLevelMeta {
  const ExperienceLevelMeta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tier,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int tier;

  static ExperienceLevelMeta of(BuildContext context, String level) {
    final c = context.colors;
    final key = level.trim().toLowerCase();

    if (key.contains('begin')) {
      return ExperienceLevelMeta(
        label: 'Beginner',
        subtitle: 'Learning fundamentals & guided tasks',
        icon: Icons.eco_rounded,
        color: c.success,
        tier: 1,
      );
    }
    if (key.contains('junior')) {
      return ExperienceLevelMeta(
        label: 'Junior',
        subtitle: 'Building features & real projects',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF0EA5E9),
        tier: 2,
      );
    }
    if (key.contains('adv') || key.contains('senior') || key.contains('lead')) {
      return ExperienceLevelMeta(
        label: level.trim(),
        subtitle: 'Leading architecture & mentoring',
        icon: Icons.workspace_premium_rounded,
        color: c.warning,
        tier: 4,
      );
    }
    return ExperienceLevelMeta(
      label: level.trim().isEmpty ? 'Intermediate' : level.trim(),
      subtitle: 'Shipping end-to-end independently',
      icon: Icons.bolt_rounded,
      color: c.primary,
      tier: 3,
    );
  }
}

// Unified experience level badge with level-specific icon and color tint.
class AppLevelBadge extends StatelessWidget {
  const AppLevelBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  final String level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final meta = ExperienceLevelMeta.of(context, level);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: meta.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: compact ? 12 : 13, color: meta.color),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: compact
                ? AppStyles.caption10Bold(context, color: meta.color)
                : AppStyles.body11Bold(context, color: meta.color),
          ),
        ],
      ),
    );
  }
}
