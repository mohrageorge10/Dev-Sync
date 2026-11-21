import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Recommended project card on the home feed.
class AdvancedProject extends StatelessWidget {
  const AdvancedProject({
    super.key,
    required this.badgeText,
    required this.timeAgoText,
    required this.title,
    required this.description,
    required this.matchPercentageText,
    required this.matchReasonText,
    required this.techStacks,
    required this.membersText,
    this.projectIcon = Icons.bolt_rounded,
    this.matchIcon = Icons.bolt_rounded,
    this.isSaved = false,
    this.isApplied = false,
    this.onTap,
    this.onBookmarkPressed,
    this.onQuickApplyPressed,
  });

  final String badgeText;
  final String timeAgoText;
  final String title;
  final String description;
  final String matchPercentageText;
  final String matchReasonText;
  final List<String> techStacks;
  final String membersText;
  final IconData projectIcon;
  final IconData matchIcon;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onQuickApplyPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(projectIcon, color: c.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        badgeText.toLowerCase() == 'learning'
                            ? AppBadge.learning(context)
                            : AppBadge.realWorld(context),
                        Text(
                          timeAgoText,
                          style: AppStyles.body12Secondary(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: AppStyles.title15Bold(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onBookmarkPressed,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? c.primary : c.textSecondary,
                  size: 20,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Project summary.
          Text(
            description,
            style: AppStyles.body13Secondary(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Compatibility banner.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(matchIcon, color: c.primary, size: 18),
                const SizedBox(width: 6),
                Text(matchPercentageText, style: AppStyles.body12Bold(context)),
                Text(' • ', style: AppStyles.body12Secondary(context)),
                Expanded(
                  child: Text(
                    matchReasonText,
                    style: AppStyles.body12Secondary(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Required skills.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in techStacks) AppSkillChip(label: s)],
          ),
          const SizedBox(height: 8),

          // Capacity and quick apply footer.
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.group_outlined, size: 18, color: c.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    membersText,
                    style: AppStyles.body12Medium(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                isApplied
                    ? AppBadge.success(context, 'Applied')
                    : ElevatedButton(
                        onPressed: onQuickApplyPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.backgroundPrimary,
                          foregroundColor: c.primary,
                          elevation: 0,
                          side: BorderSide(color: c.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Quick Apply',
                          style: AppStyles.body11SemiBold(
                            context,
                            color: c.primary,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}