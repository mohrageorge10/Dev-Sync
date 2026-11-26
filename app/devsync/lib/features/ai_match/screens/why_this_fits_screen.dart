import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_actions_ui.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:devsync/features/ai_match/widgets/rate_recommendation_sheet.dart';
import 'package:devsync/features/ai_match/widgets/why_this_fits/why_footer_cards.dart';
import 'package:devsync/features/ai_match/widgets/why_this_fits/why_header_cards.dart';
import 'package:devsync/features/ai_match/widgets/why_this_fits/why_skills_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Explains why the AI recommended a project and owns its MatchActionsCubit.
class WhyThisFitsScreen extends StatelessWidget {
  const WhyThisFitsScreen({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchActionsCubit>(
      create: (_) =>
          ServiceLocator.get<MatchActionsCubit>()..load(match.projectId),
      child: _WhyThisFitsView(match: match),
    );
  }
}

class _WhyThisFitsView extends StatefulWidget {
  const _WhyThisFitsView({required this.match});

  final MatchModel match;

  @override
  State<_WhyThisFitsView> createState() => _WhyThisFitsViewState();
}

class _WhyThisFitsViewState extends State<_WhyThisFitsView> {
  bool? _rated;

  MatchModel get match => widget.match;

  List<String> get _learnPoints => match.learnPoints.isNotEmpty
      ? match.learnPoints
      : [
          for (final t in match.learningTips)
            if (t.tip.isNotEmpty) t.tip,
        ];

  Future<void> _rate({bool? helpful}) async {
    final result = await showRateRecommendationSheet(
      context,
      match: match,
      initialHelpful: helpful,
    );
    if (result != null && mounted) setState(() => _rated = result);
  }

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(
        text: '${match.projectTitle} — ${match.score}% match for me on DevSync',
      ),
    );
    if (!mounted) return;
    AppFeedback.show(
      context,
      message: AiMatchStrings.copiedMsg,
      type: AppFeedbackType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final learn = _learnPoints;

    return BlocConsumer<MatchActionsCubit, MatchActionsState>(
      listenWhen: (prev, curr) =>
          curr.event != null && prev.event != curr.event,
      listener: (context, state) =>
          handleMatchActionEvent(context, state.event!),
      builder: (context, actions) {
        final actionsCubit = context.read<MatchActionsCubit>();

        return Scaffold(
          backgroundColor: c.surface,
          appBar: const MatchTopBar(title: AiMatchStrings.whyTitle),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              WhyHeaderSection(
                match: match,
                isSaved: actions.saved,
                onToggleSave: () => actionsCubit.toggleSaved(match),
                onShare: _share,
              ),
              const SizedBox(height: 12),
              WhySkillsSection(match: match),
              if (learn.isNotEmpty) ...[
                WhyLearningCard(points: learn),
                const SizedBox(height: 12),
              ],
              WhyRateCard(rated: _rated, onRate: _rate),
            ],
          ),
          bottomNavigationBar: WhyBottomBar(
            actions: actions,
            onViewSkillGap: () => Navigator.pushNamed(
              context,
              AppRoutes.skillGap,
              arguments: (match: match, actionsCubit: actionsCubit),
            ),
            onRequestJoin: () => actionsCubit.requestToJoin(match),
          ),
        );
      },
    );
  }
}
