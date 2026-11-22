import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/business_logic/match_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_state.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_history_card.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:devsync/features/ai_match/widgets/profile_tip_banner.dart';
import 'package:devsync/features/auth/screens/login_required_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Texts that exist only in this screen's design.
const String _subtitle =
    'Review past project recommendations and AI match insights tailored to '
    'your technical footprint.';
const String _streamTitle = 'MATCHED PROJECT STREAM';
const String _sortedLabel = 'Sorted by relevance';

/// List of projects the AI recommended to the user (best score first).
/// Needs a [MatchCubit] above it (see AppRouter).
class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _tab = 0;

  void _openWhy(MatchModel match) =>
      Navigator.pushNamed(context, AppRoutes.matchWhy, arguments: match);

  void _comingSoon() => AppFeedback.show(
        context,
        message: AiMatchStrings.comingSoon,
        type: AppFeedbackType.info,
      );

  // Signed out: the profile needs an account first. Signed in: the profile
  // screen is not built yet.
  void _completeProfile(bool signedIn) {
    if (signedIn) {
      _comingSoon(); // TODO: open the profile screen
    } else {
      showLoginRequiredSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const MatchTopBar(title: AiMatchStrings.historyTitle),
      body: BlocBuilder<MatchCubit, MatchState>(
        builder: (context, state) {
          if (state is MatchError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 36, color: c.textSecondary),
                    const SizedBox(height: 12),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: AppStyles.body15(context, active: false)),
                    const SizedBox(height: 16),
                    AppSecondaryButton(
                      buttonText: 'Try again',
                      onPressed: () => context.read<MatchCubit>().load(),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! MatchLoaded) {
            return Center(child: CircularProgressIndicator(color: c.primary));
          }

          final all = state.matches; // already sorted by score
          final strong = all.where((m) => m.fit == MatchFit.strong).toList();
          final shown = _tab == 0 ? all : strong;

          return RefreshIndicator(
            color: c.primary,
            onRefresh: () async {
              await Future.wait([
                context.read<MatchCubit>().load(silent: true),
                context.read<ProfileTipCubit>().load(),
              ]);
            },
            child: ListView(
              // Lets the user pull to refresh even with a short list.
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(_subtitle, style: AppStyles.body12Secondary(context)),
                const SizedBox(height: 12),
                AppSegmentedControl(
                  labels: [
                    'Matches (${all.length})',
                    '${AiMatchStrings.tabStrong} (${strong.length})',
                  ],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                BlocBuilder<ProfileTipCubit, ProfileTipState>(
                  builder: (context, tip) {
                    if (!tip.visible) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ProfileTipBanner(
                        calibratedPercent: tip.percent,
                        onComplete: () => _completeProfile(tip.signedIn),
                        onDismiss: () =>
                            context.read<ProfileTipCubit>().dismiss(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _streamTitle,
                        style: AppStyles.overline9Bold(context,
                            color: c.textSecondary),
                      ),
                    ),
                    Text(_sortedLabel,
                        style: AppStyles.body11Secondary(context)),
                  ],
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  _EmptyState(
                    message: _tab == 0
                        ? AiMatchStrings.emptyHistory
                        : AiMatchStrings.emptyStrong,
                  )
                else
                  for (final m in shown) ...[
                    MatchHistoryCard(
                      match: m,
                      onOpenProject: _comingSoon, // TODO: project details
                      onWhy: () => _openWhy(m),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Message shown when a tab has no matches.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 32, color: c.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppStyles.body15(context, active: false),
          ),
        ],
      ),
    );
  }
}
