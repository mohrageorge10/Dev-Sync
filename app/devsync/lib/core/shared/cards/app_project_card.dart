
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Project overview card.
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
  final bool isRealWorld;
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
          // Purpose and match badges.
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

          // Title and description.
          Text(title, style: AppStyles.h2(context)),
          const SizedBox(height: 8),
          Text(description, style: AppStyles.body14Secondary(context)),
          const SizedBox(height: 16),

          // Required skills.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in skills) AppSkillChip(label: s)],
          ),
          const SizedBox(height: 16),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 16),

          // Capacity and action footer.
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 18, color: c.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '$members/$capacity members',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.label14SemiBold(
                              context,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                isDisabled: false,
                onPressed: onViewProject,
              ),
            ],
          ),
        ],
      ),
    );
  }
}