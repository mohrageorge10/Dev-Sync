import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_actions_ui.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:devsync/features/ai_match/widgets/skill_gap/skill_gap_header_cards.dart';
import 'package:devsync/features/ai_match/widgets/skill_gap/skill_gap_skills_cards.dart';
import 'package:devsync/features/ai_match/widgets/skill_gap/skill_gap_tips_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Displays matched capabilities, skill gaps, preparation tips, and join CTA.
class SkillGapScreen extends StatelessWidget {
  const SkillGapScreen({
    super.key,
    required this.match,
    this.useProvidedActionsCubit = false,
  });

  final MatchModel match;
  final bool useProvidedActionsCubit;

  @override
  Widget build(BuildContext context) {
    if (useProvidedActionsCubit) {
      return _SkillGapView(match: match);
    }
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
              SkillGapGrowthCard(projectTitle: match.projectTitle),
              if (total > 0) ...[
                const SizedBox(height: 12),
                SkillGapProgressCard(
                  matched: matched,
                  total: total,
                  hasGap: missing.isNotEmpty,
                ),
              ],
              if (matched > 0) ...[
                const SizedBox(height: 12),
                SkillGapMatchedCard(match: match),
              ],
              if (total > 0) ...[
                const SizedBox(height: 12),
                SkillGapRequirementsCard(match: match),
              ],
              if (tips.isNotEmpty) ...[
                const SizedBox(height: 12),
                SkillGapImproveCard(tips: tips),
              ],
              if (match.highlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                SkillGapMentorshipCard(highlights: match.highlights),
              ],
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
