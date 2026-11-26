import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/input_fields/app_search_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/discover_header.dart';
import 'package:devsync/features/discover_project/presentation/widgets/discover_tabs_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Discover search screen for projects and developers.
class SearchScreen extends StatelessWidget {
  final int initialTab;

  const SearchScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DiscoverCubitScope(
      initialTab: initialTab,
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<DiscoverCubit>();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: CustomAppBar(
        title: 'DevSync',
        leading: Align(
          alignment: Alignment.center,
          child: canPop
              ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back, color: c.textPrimary),
                )
              : const DevSyncLogo(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<DiscoverCubit, DiscoverState>(
              buildWhen: (a, b) =>
                  a.tab != b.tab ||
                  a.allProjects != b.allProjects ||
                  a.allDevelopers != b.allDevelopers,
              builder: (context, state) => DiscoverHeader(
                title: 'Discover',
                subtitle: 'Find the perfect technical collaborator',
                badgeText: state.headerBadge,
              ),
            ),
            BlocBuilder<DiscoverCubit, DiscoverState>(
              buildWhen: (a, b) => a.tab != b.tab,
              builder: (context, state) => AppSearchField(
                hintText: state.searchHint,
                controller: cubit.searchController,
                onChanged: cubit.search,
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
              ),
            ),
            const Expanded(child: DiscoverTabsSection()),
          ],
        ),
      ),
    );
  }
}
