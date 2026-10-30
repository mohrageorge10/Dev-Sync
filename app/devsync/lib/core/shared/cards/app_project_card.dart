
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppProjectCard extends StatelessWidget {
  const AppProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.skills,
    required this.members,
    required this.capacity,
    required this.onViewProject,
    this.isRealWorld = true,
    this.matchPercent,
  });

  final String title;
  final String description;
  final List<String> skills;
  final int members;
  final int capacity;
  final VoidCallback onViewProject;

  /// true = REAL-WORLD badge, false = LEARNING badge.
  final bool isRealWorld;

  /// Shows "89% Match" when not null.
  final int? matchPercent;

  bool get _isFull => members >= capacity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purpose + match
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isRealWorld
                  ? AppBadge.realWorld(context)
                  : AppBadge.learning(context),
              if (matchPercent != null)
                AppBadge(
                  label: '$matchPercent% Match',
                  color: c.primary,
                  backgroundColor: c.subtleBlueSurface,
                  showBorder: true,
                  icon: Icons.bolt_rounded,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Title + description
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              height: 28 / 22,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Skills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in skills) AppSkillChip(label: s)],
          ),
          const SizedBox(height: 16),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_outlined, size: 20, color: c.primary),
                        const SizedBox(width: 6),
                        Text(
                          '$members/$capacity members',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    _isFull
                        ? AppBadge.info(context, 'Full')
                        : AppBadge.success(context, 'Open'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppPrimaryButton(
                buttonText: 'View Project',
                trailingIcon: Icons.chevron_right_rounded,
                isDisabled: false, // default is true in your button!
                onPressed: onViewProject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}