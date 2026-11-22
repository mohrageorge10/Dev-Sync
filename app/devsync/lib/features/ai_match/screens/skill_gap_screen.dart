import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_icons.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_actions_ui.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Texts that exist only in this screen's design.
const String _growthIntro =
    'Every great open-source contribution is a chance to level up. '
    'Here is how your skills connect with ';
const String _gapNote = ' This gap is ideal for active mentorship.';
const String _verified = 'Verified';
const String _coreStack = 'CORE STACK (REQUIRED)';
const String _growthAreas = 'GROWTH AREAS (LEARN ON THE JOB)';
const String _improveTitle = 'Skills to Improve & How to Prepare';
const String _whyLabel = 'Why it matters: ';
const String _whatLabel = 'What to learn: ';
const String _firstStepLabel = 'First step: ';
const String _mentorTitle = 'Mentorship & Growth Highlights';
const String _mentorSubtitle = 'What this project gives back to your career';

/// Shows what the user already has, what is missing and how to prepare.
/// Owns the [MatchActionsCubit] (join request) of this project.
class SkillGapScreen extends StatelessWidget {
  const SkillGapScreen({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchActionsCubit>(
      create: (_) =>
          ServiceLocator.get<MatchActionsCubit>()..load(match.projectId),
      child: _SkillGapView(match: match),
    );
  }
}

class _SkillGapView extends StatelessWidget {
  const _SkillGapView({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = match.requiredCount;
    final matched = match.matchedSkills.length;
    final missing = match.missingSkills;
    final tips = match.learningTips;

    return BlocConsumer<MatchActionsCubit, MatchActionsState>(
      listenWhen: (prev, curr) =>
          curr.event != null && prev.event != curr.event,
      listener: (context, state) =>
          handleMatchActionEvent(context, state.event!),
      builder: (context, actions) {
        final join = joinButtonSpec(actions);

        return Scaffold(
          backgroundColor: c.surface,
          appBar: const MatchTopBar(title: AiMatchStrings.gapTitle),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GrowthCard(projectTitle: match.projectTitle),

              if (total > 0) ...[
                const SizedBox(height: 12),
                _ProgressCard(
                  matched: matched,
                  total: total,
                  hasGap: missing.isNotEmpty,
                ),
              ],

              // Skills the user already has
              if (matched > 0) ...[
                const SizedBox(height: 12),
                MatchCard(
                  title: '${AiMatchStrings.skillsYouHave} ($matched/$total)',
                  icon: Icons.check_circle_rounded,
                  iconColor: c.primary,
                  trailing: MatchTag(
                    label: _verified,
                    color: c.primary,
                    background: c.subtle(c.primary),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < matched; i++) ...[
                        if (i > 0)
                          Divider(color: c.border, height: 24, thickness: 1),
                        _SkillRow(
                          name: match.matchedSkills[i],
                          detail: match.detailFor(match.matchedSkills[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Requirements breakdown
              if (total > 0) ...[
                const SizedBox(height: 12),
                MatchCard(
                  title: AiMatchStrings.requirements,
                  icon: Icons.terminal_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matched > 0) ...[
                        _SectionLabel(
                          label: _coreStack,
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
                          label: _growthAreas,
                          value: '${missing.length} '
                              'topic${missing.length == 1 ? '' : 's'}',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in missing) _SkillPill(label: s),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // How to prepare
              if (tips.isNotEmpty) ...[
                const SizedBox(height: 12),
                MatchCard(
                  title: _improveTitle,
                  icon: Icons.school_outlined,
                  child: Column(
                    children: [
                      for (var i = 0; i < tips.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _FocusCard(index: i + 1, tip: tips[i]),
                      ],
                    ],
                  ),
                ),
              ],

              // Mentorship highlights
              if (match.highlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                MatchCard(
                  background: c.subtleBlueSurface,
                  borderColor: c.primary.withValues(alpha: 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _IconTile(
                            icon: Icons.school_outlined,
                            size: 36,
                            filled: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_mentorTitle,
                                    style: AppStyles.title15Bold(context)),
                                Text(_mentorSubtitle,
                                    style: AppStyles.body11Secondary(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < match.highlights.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _HighlightRow(
                            index: i, highlight: match.highlights[i]),
                      ],
                    ],
                  ),
                ),
              ],

              // Actions
              const SizedBox(height: 20),
              MatchActionButton(
                label: join.label,
                leadingIcon: join.lead,
                trailingIcon: join.trail,
                filled: join.filled,
                enabled: join.enabled,
                loading: join.loading,
                onTap: () =>
                    context.read<MatchActionsCubit>().requestToJoin(match),
              ),
              const SizedBox(height: 12),
              MatchActionButton(
                label: AiMatchStrings.backToProject,
                onTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ======================= Pieces of the screen =======================

/// Small rounded square with an icon inside (skills, focus cards...).
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    this.size = 36,
    this.filled = false,
  });

  final IconData icon;
  final double size;

  /// true = solid blue tile with a white icon.
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

/// "Your growth opportunities" blue card on top.
class _GrowthCard extends StatelessWidget {
  const _GrowthCard({required this.projectTitle});

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
          const _IconTile(icon: Icons.auto_awesome_rounded, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AiMatchStrings.growthTitle,
                    style: AppStyles.title15Bold(context)),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: AppStyles.body12Primary(context)
                        .copyWith(height: 1.4),
                    children: [
                      const TextSpan(text: _growthIntro),
                      TextSpan(
                        text: projectTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.primary,
                        ),
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

/// Progress bar + "You match 4 of 6 required core capabilities."
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
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
    final ratio = total == 0 ? 0.0 : (matched / total).clamp(0.0, 1.0).toDouble();
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
            '${hasGap ? _gapNote : ''}',
            style: AppStyles.body11Secondary(context),
          ),
        ],
      ),
    );
  }
}

/// One skill the user already has: icon, name, level tag and note.
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
        _IconTile(icon: skillIconFor(name), size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(name,
                        style: AppStyles.label14SemiBold(context)),
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

/// "CORE STACK (REQUIRED) ........ 3 of 6 ready"
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

/// Round skill chip: [checked] = white with a blue check (skill is ready),
/// otherwise soft blue (skill to learn).
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
        border:
            checked ? Border.all(color: c.primary.withValues(alpha: 0.35)) : null,
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "KEY FOCUS 01": why it matters, what to learn and the first step.
class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.index, required this.tip});

  final int index;
  final LearningTip tip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Old data only has `tip`: show it as the first step.
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
              _IconTile(
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
                      label: _whyLabel,
                      text: tip.whyItMatters,
                    ),
                  if (tip.whyItMatters.isNotEmpty &&
                      tip.whatToLearn.isNotEmpty)
                    const SizedBox(height: 8),
                  if (tip.whatToLearn.isNotEmpty)
                    _LabeledLine(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: c.textSecondary,
                      label: _whatLabel,
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
                label: _firstStepLabel,
                text: firstStep,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// `code` becomes monospace, #hashtag becomes blue.
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
      spans.add(TextSpan(
        text: code,
        style: TextStyle(
          fontFamily: 'monospace',
          fontFamilyFallback: const ['Courier New', 'Courier', 'Roboto Mono'],
          fontSize: 11,
          color: c.textPrimary,
          backgroundColor: c.primary.withValues(alpha: 0.10),
        ),
      ));
    } else {
      spans.add(TextSpan(
        text: m.group(2),
        style: TextStyle(color: c.primary, fontWeight: FontWeight.w600),
      ));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return spans;
}

/// Icon + bold label + text ("Why it matters: ...").
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

/// One white row inside "Mentorship & Growth Highlights".
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
                  // No internet / bad link: show the person icon instead.
                  errorBuilder: (_, __, ___) => const _IconTile(
                    icon: Icons.person_outline_rounded,
                    size: 36,
                  ),
                ),
              ),
            )
          else
            _IconTile(
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
                  Text(highlight.subtitle,
                      style: AppStyles.body11Secondary(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
