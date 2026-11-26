import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/team_widgets.dart';

// Main screen displaying teams the user belongs to.
class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final teams = state.teams;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'My Teams',
        leading: embedded
            ? const Align(alignment: Alignment.center, child: DevSyncLogo())
            : Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        onNotificationTap: () => showSnack(context, 'No new notifications'),
      ),
      body: state.isLoading && teams.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => state.loadData(force: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (teams.isEmpty)
                    const _EmptyTeamsState()
                  else ...[
                    const SectionHeader(
                      'Collaborative Squads',
                      trailing: 'IN PROGRESS',
                    ),
                    for (final t in teams) ...[
                      TeamCard(
                        team: t,
                        openTasks: state.openTasksCount(t.id),
                        onOpen: () => AppRouter.toWorkspace(context, t),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  const SizedBox(height: 4),
                  _ExplorePromo(
                    onExplore: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.discoverSearch, arguments: 0),
                  ),
                ],
              ),
            ),
    );
  }
}

// Empty state shown when the user has not joined any team yet.
class _EmptyTeamsState extends StatelessWidget {
  const _EmptyTeamsState();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups_outlined, size: 30, color: c.primary),
          ),
          const SizedBox(height: 12),
          Text('No teams yet', style: AppStyles.title16Bold(context)),
          const SizedBox(height: 4),
          Text(
            'Join an open project or create your own to start collaborating.',
            textAlign: TextAlign.center,
            style: AppStyles.body13Secondary(context),
          ),
        ],
      ),
    );
  }
}

// Promotional banner encouraging project discovery.
class _ExplorePromo extends StatelessWidget {
  const _ExplorePromo({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.border),
            ),
            child: Icon(Icons.hub_outlined, size: 38, color: c.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Looking to build something new?',
            style: AppStyles.body14Bold(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Find open-source projects actively looking for contributors with your exact tech stack.',
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: c.backgroundPrimary,
                foregroundColor: c.primary,
                side: BorderSide(color: c.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.explore_outlined, size: 16),
              label: Text(
                'Explore Projects',
                style: AppStyles.body13Bold(context, color: c.primary),
              ),
              onPressed: onExplore,
            ),
          ),
        ],
      ),
    );
  }
}
