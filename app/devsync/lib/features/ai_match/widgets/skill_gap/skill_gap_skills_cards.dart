import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_icons.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:devsync/features/ai_match/widgets/skill_gap/skill_gap_header_cards.dart';
import 'package:flutter/material.dart';

// Card listing verified skills the developer already has for this project.
class SkillGapMatchedCard extends StatelessWidget {
  const SkillGapMatchedCard({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final matched = match.matchedSkills.length;
    final total = match.requiredCount;

    return MatchCard(
      title: '${AiMatchStrings.skillsYouHave} ($matched/$total)',
      icon: Icons.check_circle_rounded,
      iconColor: c.primary,
      trailing: MatchTag(
        label: 'Verified',
        color: c.primary,
        background: c.subtle(c.primary),
      ),
      child: Column(
        children: [
          for (var i = 0; i < matched; i++) ...[
            if (i > 0) Divider(color: c.border, height: 24, thickness: 1),
            _SkillRow(
              name: match.matchedSkills[i],
              detail: match.detailFor(match.matchedSkills[i]),
            ),
          ],
        ],
      ),
    );
  }
}

// Card breaking down required core stack vs growth areas to learn on the job.
class SkillGapRequirementsCard extends StatelessWidget {
  const SkillGapRequirementsCard({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final matched = match.matchedSkills.length;
    final total = match.requiredCount;
    final missing = match.missingSkills;

    return MatchCard(
      title: AiMatchStrings.requirements,
      icon: Icons.terminal_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matched > 0) ...[
            _SectionLabel(
              label: 'CORE STACK (REQUIRED)',
              value: '$matched of $total ready',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in match.matchedSkills)
                  _SkillPill(label: s, checked: true),
              ],
            ),
          ],
          if (matched > 0 && missing.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: c.border, height: 1),
            ),
          if (missing.isNotEmpty) ...[
            _SectionLabel(
              label: 'GROWTH AREAS (LEARN ON THE JOB)',
              value: '${missing.length} topic${missing.length == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final s in missing) _SkillPill(label: s)],
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.name, this.detail});

  final String name;
  final SkillDetail? detail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final note = detail?.note ?? '';
    final level = detail?.level ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkillGapIconTile(icon: skillIconFor(name), size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppStyles.label14SemiBold(context),
                    ),
                  ),
                  if (level.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    MatchTag(
                      label: level,
                      color: c.primary,
                      background: c.subtle(c.primary),
                    ),
                  ],
                ],
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(note, style: AppStyles.body11Secondary(context)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppStyles.overline9Bold(context, color: c.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: AppStyles.body11Bold(context, color: c.primary)),
      ],
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label, this.checked = false});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: checked ? c.backgroundPrimary : c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(999),
        border: checked
            ? Border.all(color: c.primary.withValues(alpha: 0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (checked) ...[
            Icon(Icons.check_rounded, size: 14, color: c.primary),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: AppStyles.body12SemiBold(context, color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
