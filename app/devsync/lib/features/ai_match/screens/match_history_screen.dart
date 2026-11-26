import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/sheets/login_required_sheet.dart';
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
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
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

  // Open the matched project in ProjectDetailsScreen (uses DiscoverCubit if loaded).
  void _openProject(MatchModel match) {
    ProjectModel? resolved;
    if (ServiceLocator.isRegistered<DiscoverCubit>()) {
      resolved = ServiceLocator.get<DiscoverCubit>()
          .state
          .allProjects
          .where((p) => p.id == match.projectId)
          .firstOrNull;
    }
    resolved ??= ProjectModel(
      id: match.projectId,
      title: match.projectTitle,
      icon: Icons.rocket_launch_outlined,
      type: match.purpose.name == 'real' ? 'Real-world' : 'Learning',
      matchPercent: match.score,
      createdAgo: 'Recently matched',
      ageHours: 2,
      status: 'Open for Contributors',
      description: match.projectDescription,
      matchReason: match.explanation.isNotEmpty
          ? match.explanation
          : 'Matches your verified tech stack',
      tags: [...match.matchedSkills, ...match.missingSkills],
      tracks: [
        if (match.matchedTrack.isNotEmpty) match.matchedTrack else 'Mobile',
      ],
      openTracks: [
        if (match.matchedTrack.isNotEmpty) match.matchedTrack else 'Mobile',
      ],
      difficulty: 'Intermediate',
      members: 2,
      maxMembers: 5,
      needs: match.matchedTrack.isNotEmpty
          ? match.matchedTrack
          : 'Contributor',
    );
    Navigator.of(context).pushNamed(
      AppRoutes.projectDetails,
      arguments: resolved,
    );
  }

  // Open Complete Profile when signed in, or login sheet when guest.
  Future<void> _completeProfile(bool signedIn) async {
    if (!signedIn) {
      LoginRequiredSheet.show(
        context,
        message: 'Log in to complete your developer profile.',
      );
      return;
    }
    if (ServiceLocator.isRegistered<ProfileController>()) {
      await ServiceLocator.get<ProfileController>().loadProfile();
    }
    if (!mounted) return;
    await Navigator.of(context).pushNamed(AppRoutes.profileComplete);
    if (!mounted) return;
    context.read<ProfileTipCubit>().load();
    context.read<MatchCubit>().load(silent: true);
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
                      onOpenProject: () => _openProject(m),
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
