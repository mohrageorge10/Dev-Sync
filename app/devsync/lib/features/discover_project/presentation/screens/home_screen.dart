import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/headers/header.dart';
import 'package:devsync/core/shared/input_fields/app_search_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/advanced_projects_list.dart';
import 'package:devsync/features/discover_project/presentation/widgets/boost_matches_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/recommended_developers_section.dart';
import 'package:devsync/features/discover_project/presentation/widgets/welcome_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Home feed screen for authenticated users.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoverCubitScope(child: _HomeView());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  void _openSearch(BuildContext context, {int initialTab = 0}) {
    context.read<DiscoverCubit>().setTab(initialTab);
    Navigator.of(context).pushNamed(
      AppRoutes.discoverSearch,
      arguments: initialTab,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<DiscoverCubit>();

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const CustomAppBar(
        title: 'DevSync',
        leading: Align(
          alignment: Alignment.center,
          child: DevSyncLogo(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: cubit.loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<DiscoverCubit, DiscoverState>(
                  buildWhen: (a, b) => a.userName != b.userName,
                  builder: (context, state) => WelcomeHeader(
                    greeting: state.greeting,
                    userName: state.userName,
                    onAiTap: () => AppFeedback.show(
                      context,
                      title: 'AI Match Assistant',
                      message: 'AI-powered project matching is coming soon.',
                    ),
                  ),
                ),

                // Search bar shortcut.
                AppSearchField(
                  hintText: 'Search projects or developers',
                  prefixIcon: Icon(Icons.search, color: c.textSecondary),
                  onTap: () => _openSearch(context),
                ),

                // Profile completion prompt.
                BlocBuilder<DiscoverCubit, DiscoverState>(
                  buildWhen: (a, b) =>
                      a.showBoost != b.showBoost ||
                      a.profileStrength != b.profileStrength,
                  builder: (context, state) {
                    if (!state.showBoost) return const SizedBox.shrink();
                    return BoostMatchesCard(
                      strength: state.profileStrength,
                      onClosePressed: cubit.dismissBoost,
                      onCompletePressed: () => AppFeedback.show(
                        context,
                        message: 'Profile editor is coming soon.',
                      ),
                    );
                  },
                ),

                Header(
                  title: 'Recommended for you',
                  title2: 'Top matching open builds',
                  text: 'See All',
                  onTap: () => _openSearch(context, initialTab: 0),
                ),
                const AdvancedProjectsList(),

                Header(
                  title: 'Recommended developers',
                  title2: 'Talent ready to collaborate',
                  text: 'See All',
                  onTap: () => _openSearch(context, initialTab: 1),
                ),
                const RecommendedDevelopersSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
