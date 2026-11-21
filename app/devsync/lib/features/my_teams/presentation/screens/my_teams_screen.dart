import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/team_widgets.dart';
// Main screen displaying teams the user belongs to
class MyTeamsScreen extends StatelessWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final teams = state.teams;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('My Teams',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Stack(alignment: Alignment.topRight, children: [
            IconButton(
                icon: const Icon(Icons.notifications_none, size: 22),
                onPressed: () => showSnack(context, 'No new notifications')),
            const Positioned(
              right: 11,
              top: 11,
              child: Icon(Icons.circle, size: 8, color: AppPalette.danger),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppPalette.primary,
              child: Text(state.me.initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
        bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1), child: Divider(height: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Collaborative Squads', trailing: 'IN PROGRESS'),
          for (final t in teams) ...[
            TeamCard(
              team: t,
              openTasks: state.openTasksCount(t.id),
              onOpen: () => AppRouter.toWorkspace(context, t),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          _ExplorePromo(
              onExplore: () => showSnack(context, 'Discover is coming soon')),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        index: 2,
        onTap: (i) {
          if (i != 2) showSnack(context, 'This tab is coming soon');
        },
      ),
    );
  }
}

// Promotional banner encouraging project discovery
class _ExplorePromo extends StatelessWidget {
  final VoidCallback onExplore;
  const _ExplorePromo({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.border.withAlpha(110),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.hub_outlined,
              size: 44, color: AppPalette.primary),
        ),
        const SizedBox(height: 14),
        const Text('Looking to build something new?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
            'Find open-source projects actively looking for contributors with your exact tech stack.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppPalette.muted)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppPalette.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.explore_outlined, size: 16),
            label: const Text('Explore Projects',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            onPressed: onExplore,
          ),
        ),
      ]),
    );
  }
}
