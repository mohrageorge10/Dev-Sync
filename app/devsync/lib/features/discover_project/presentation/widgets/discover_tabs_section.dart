import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/screens/filter_screen.dart';
import 'package:devsync/features/discover_project/presentation/widgets/active_filter_chips.dart';
import 'package:devsync/features/discover_project/presentation/widgets/developers_content.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_sort_bar.dart';
import 'package:devsync/features/discover_project/presentation/widgets/projects_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Segmented tabs, filter/sort bar, and active results list.
class DiscoverTabsSection extends StatelessWidget {
  const DiscoverTabsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        final cubit = context.read<DiscoverCubit>();

        return Column(
          children: [
            AppSegmentedControl(
              labels: const ['Projects', 'Developers'],
              selectedIndex: state.tab,
              onChanged: cubit.setTab,
            ),
            const SizedBox(height: 12),
            FilterSortBar(
              filterCount: state.filters.activeCount,
              selectedSort: state.sort,
              onFilterTap: () => FilterScreen.show(
                context,
                initial: state.filters,
                countMatching: cubit.countMatching,
                onApply: cubit.applyFilters,
              ),
              onSortChanged: cubit.setSort,
            ),
            const SizedBox(height: 12),
            ActiveFilterChips(
              filters: state.filters.chips,
              onRemove: cubit.removeFilter,
              onClearAll: cubit.clearFilters,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppAnimations.normal,
                switchInCurve: AppAnimations.easeOut,
                switchOutCurve: Curves.easeIn,
                child: state.isProjectsTab
                    ? const ProjectsContent(key: ValueKey('projects'))
                    : const DevelopersContent(key: ValueKey('developers')),
              ),
            ),
          ],
        );
      },
    );
  }
}