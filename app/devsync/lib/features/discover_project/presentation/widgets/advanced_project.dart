import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Compact recommended project card on the home feed.
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(projectIcon, color: c.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.title15Bold(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$badgeText · $matchPercentageText',
                        style: AppStyles.body11Medium(
                          context,
                          color: c.primary,
                        ),
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
                    size: 19,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppStyles.body12Secondary(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in techStacks.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: c.border),
                          ),
                          child: Text(
                            s,
                            style: AppStyles.body11Medium(context),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onQuickApplyPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isApplied
                        ? c.subtle(c.success)
                        : c.subtleBlueSurface,
                    foregroundColor: isApplied ? c.success : c.primary,
                    elevation: 0,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isApplied ? 'Applied' : 'Apply',
                    style: AppStyles.body12Bold(
                      context,
                      color: isApplied ? c.success : c.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
