import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter/material.dart';

// Small rounded square icon tile shared across Skill Gap cards.
class SkillGapIconTile extends StatelessWidget {
  const SkillGapIconTile({
    super.key,
    required this.icon,
    this.size = 36,
    this.filled = false,
  });

  final IconData icon;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? c.primary : c.subtle(c.primary),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: filled ? c.onPrimary : c.primary,
      ),
    );
  }
}

// Intro banner card highlighting growth opportunities for the matched project.
class SkillGapGrowthCard extends StatelessWidget {
  const SkillGapGrowthCard({super.key, required this.projectTitle});

  final String projectTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkillGapIconTile(icon: Icons.auto_awesome_rounded, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AiMatchStrings.growthTitle,
                  style: AppStyles.title15Bold(context),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: AppStyles.body12Primary(
                      context,
                    ).copyWith(height: 1.4),
                    children: [
                      const TextSpan(
                        text:
                            'Every great open-source contribution is a chance to level up. Here is how your skills connect with ',
                      ),
                      TextSpan(
                        text: projectTitle,
                        style: AppStyles.body12Bold(context, color: c.primary),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated progress bar showing matched vs required capabilities.
class SkillGapProgressCard extends StatelessWidget {
  const SkillGapProgressCard({
    super.key,
    required this.matched,
    required this.total,
    required this.hasGap,
  });

  final int matched;
  final int total;
  final bool hasGap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio = total == 0 ? 0.0 : (matched / total).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: c.primary,
                backgroundColor: c.border,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You match $matched of $total required core capabilities.'
            '${hasGap ? ' This gap is ideal for active mentorship.' : ''}',
            style: AppStyles.body11Secondary(context),
          ),
        ],
      ),
    );
  }
}
