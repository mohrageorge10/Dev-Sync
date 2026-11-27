import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_icons.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:devsync/features/ai_match/widgets/skill_gap/skill_gap_header_cards.dart';
import 'package:flutter/material.dart';

// Card showing actionable preparation steps for missing skills.
class SkillGapImproveCard extends StatelessWidget {
  const SkillGapImproveCard({super.key, required this.tips});

  final List<LearningTip> tips;

  @override
  Widget build(BuildContext context) {
    return MatchCard(
      title: 'Skills to Improve & How to Prepare',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _FocusCard(index: i + 1, tip: tips[i]),
          ],
        ],
      ),
    );
  }
}

// Card highlighting mentorship and career growth benefits of the project.
class SkillGapMentorshipCard extends StatelessWidget {
  const SkillGapMentorshipCard({super.key, required this.highlights});

  final List<MatchHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MatchCard(
      background: c.subtleBlueSurface,
      borderColor: c.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkillGapIconTile(
                icon: Icons.school_outlined,
                size: 36,
                filled: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mentorship & Growth Highlights',
                      style: AppStyles.title15Bold(context),
                    ),
                    Text(
                      'What this project gives back to your career',
                      style: AppStyles.body11Secondary(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _HighlightRow(index: i, highlight: highlights[i]),
          ],
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.index, required this.tip});

  final int index;
  final LearningTip tip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final firstStep = tip.firstStep.isNotEmpty ? tip.firstStep : tip.tip;
    final hasInfo = tip.whyItMatters.isNotEmpty || tip.whatToLearn.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              Expanded(
                child: Text(
                  'KEY FOCUS ${index.toString().padLeft(2, '0')}',
                  style: AppStyles.overline9Bold(context, color: c.primary),
                ),
              ),
              SkillGapIconTile(
                icon: skillIconFor(tip.skill, fallback: Icons.insights_rounded),
                size: 28,
              ),
            ],
          ),
          if (tip.skill.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(tip.skill, style: AppStyles.title15Bold(context)),
          ],
          if (hasInfo) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tip.whyItMatters.isNotEmpty)
                    _LabeledLine(
                      icon: Icons.info_outline_rounded,
                      iconColor: c.textSecondary,
                      label: 'Why it matters: ',
                      text: tip.whyItMatters,
                    ),
                  if (tip.whyItMatters.isNotEmpty && tip.whatToLearn.isNotEmpty)
                    const SizedBox(height: 8),
                  if (tip.whatToLearn.isNotEmpty)
                    _LabeledLine(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: c.textSecondary,
                      label: 'What to learn: ',
                      text: tip.whatToLearn,
                    ),
                ],
              ),
            ),
          ],
          if (firstStep.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.primary.withValues(alpha: 0.25)),
              ),
              child: _LabeledLine(
                icon: Icons.flag_outlined,
                iconColor: c.primary,
                label: 'First step: ',
                text: firstStep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final RegExp _inlineToken = RegExp(r'`([^`]+)`|(#[\w-]+)');

List<InlineSpan> _formatInline(BuildContext context, String text) {
  final c = context.colors;
  final spans = <InlineSpan>[];
  var last = 0;
  for (final m in _inlineToken.allMatches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start)));
    }
    final code = m.group(1);
    if (code != null) {
      spans.add(
        TextSpan(
          text: code,
          style: TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Courier New', 'Courier', 'Roboto Mono'],
            fontSize: 11,
            color: c.textPrimary,
            backgroundColor: c.primary.withValues(alpha: 0.10),
          ),
        ),
      );
    } else {
      spans.add(
        TextSpan(
          text: m.group(2),
          style: AppStyles.body12SemiBold(context, color: c.primary),
        ),
      );
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

class _LabeledLine extends StatelessWidget {
  const _LabeledLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: AppStyles.body12Primary(context).copyWith(height: 1.4),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                ..._formatInline(context, text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.index, required this.highlight});

  final int index;
  final MatchHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final url = highlight.avatarUrl;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url.isNotEmpty)
            ClipOval(
              child: SizedBox(
                width: 36,
                height: 36,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SkillGapIconTile(
                    icon: Icons.person_outline_rounded,
                    size: 36,
                  ),
                ),
              ),
            )
          else
            SkillGapIconTile(
              icon: highlightIconFor(highlight.title, index),
              size: 36,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(highlight.title, style: AppStyles.body12Bold(context)),
                if (highlight.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    highlight.subtitle,
                    style: AppStyles.body11Secondary(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
