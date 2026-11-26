import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';

// Matched, complementary, and missing skills breakdown cards for WhyThisFitsScreen.
class WhySkillsSection extends StatelessWidget {
  const WhySkillsSection({super.key, required this.match});

  final MatchModel match;

  String get _shortName =>
      match.projectTitle.split(RegExp(r'[:\s]')).first.trim();

  IconData _skillIcon(String skill) =>
      RegExp(r'\b(ble|bluetooth)\b', caseSensitive: false).hasMatch(skill)
      ? Icons.bluetooth_rounded
      : Icons.circle_outlined;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        if (match.matchedSkills.isNotEmpty) ...[
          MatchCard(
            title: AiMatchStrings.matchedSkills,
            icon: Icons.check_circle_rounded,
            iconColor: c.primary,
            trailing: Text(
              '${match.matchedSkills.length} of ${match.matchedSkills.length} verified',
              style: AppStyles.body11Secondary(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills from your verified stack that directly solve $_shortName issues:',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in match.matchedSkills)
                      _VerifiedChip(label: s),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (match.complementarySkills.isNotEmpty) ...[
          MatchCard(
            title: AiMatchStrings.complementarySkills,
            icon: Icons.extension_outlined,
            iconColor: c.primary,
            trailing: Text(
              'Value-Add',
              style: AppStyles.body12Bold(context, color: c.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secondary proficiencies that elevate your code review speed and architectural stability.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in match.complementarySkills)
                      _PillChip(
                        label: s,
                        background: c.subtle(c.primary),
                        foreground: c.darkBlueAccent,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'These skills will help optimize the architecture and speed up issue triage.',
                        style: AppStyles.body12Secondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (match.missingSkills.isNotEmpty) ...[
          MatchCard(
            title: 'Skills to Develop',
            icon: Icons.trending_up_rounded,
            iconColor: c.warning,
            trailing: MatchTag(
              label: 'Mentored',
              color: c.warning,
              background: c.subtle(c.warning),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in match.missingSkills)
                      _PillChip(
                        label: s,
                        background: c.subtle(c.warning),
                        foreground: c.textPrimary,
                        icon: _skillIcon(s),
                        iconColor: c.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Not required immediately — the maintainers offer onboarding mentorship and pair programming sessions.',
                          style: AppStyles.body12Secondary(
                            context,
                          ).copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppStyles.body12SemiBold(context, color: c.onPrimary)),
          const SizedBox(width: 4),
          Icon(Icons.check_rounded, size: 14, color: c.onPrimary),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.iconColor,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppStyles.body12SemiBold(context, color: foreground),
          ),
        ],
      ),
    );
  }
}
