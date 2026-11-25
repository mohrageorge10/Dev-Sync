import 'package:devsync/core/shared/input_fields/app_search_field.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/features/discover_project/data/model/filter_options_data.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_chips_group.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_section.dart';
import 'package:devsync/features/discover_project/presentation/widgets/matching_opportunities_card.dart';
import 'package:flutter/material.dart';

// Scrollable list of filter sections.
class FilterSectionsList extends StatelessWidget {
  const FilterSectionsList({
    super.key,
    required this.state,
    required this.onChanged,
    required this.matchingCount,
  });

  final FilterState state;
  final ValueChanged<FilterState> onChanged;
  final int matchingCount;

  List<String> get _visibleSkills => FilterOptionsData.skills
      .where((s) => s.toLowerCase().contains(state.skillsQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final teamSizes = FilterOptionsData.teamSizes;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skills filter.
          FilterSection(
            icon: FilterOptionsData.skillsIcon,
            title: 'Skills',
            trailingText: 'Multi-select',
            child: Column(
              children: [
                AppSearchField(
                  hintText: 'Search skills...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  onChanged: (v) => onChanged(state.copyWith(skillsQuery: v)),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChipsGroup(
                    options: _visibleSkills,
                    selected: state.skills,
                    onChanged: (v) => onChanged(state.copyWith(skills: v)),
                  ),
                ),
              ],
            ),
          ),

          // Tracks & roles filter (from UserTrack).
          FilterSection(
            icon: FilterOptionsData.tracksIcon,
            title: 'Tracks & Roles Needed',
            trailingText: 'Multi-select',
            child: FilterChipsGroup(
              options: FilterOptionsData.tracks,
              selected: state.tracks,
              onChanged: (v) => onChanged(state.copyWith(tracks: v)),
            ),
          ),

          // Project purpose filter (from ProjectPurpose).
          FilterSection(
            icon: FilterOptionsData.purposeIcon,
            title: 'Project Purpose',
            child: AppSegmentedControl(
              labels: FilterOptionsData.purposes,
              selectedIndex: FilterOptionsData.purposes.indexOf(state.purpose),
              onChanged: (i) => onChanged(
                state.copyWith(purpose: FilterOptionsData.purposes[i]),
              ),
            ),
          ),

          // Difficulty level filter (all 4 ProjectDifficulty levels).
          FilterSection(
            icon: FilterOptionsData.difficultyIcon,
            title: 'Difficulty Level',
            child: FilterChipsGroup(
              options: FilterOptionsData.difficulty,
              selected: state.difficulty,
              multiSelect: false,
              onChanged: (v) => onChanged(state.copyWith(difficulty: v)),
            ),
          ),

          // Team size filter.
          FilterSection(
            icon: FilterOptionsData.teamIcon,
            title: 'Team Size',
            child: AppSegmentedControl(
              labels: teamSizes,
              selectedIndex: state.teamSize.isEmpty
                  ? -1
                  : teamSizes.indexOf(state.teamSize.first),
              onChanged: (i) =>
                  onChanged(state.copyWith(teamSize: {teamSizes[i]})),
            ),
          ),

          // Project status filter.
          FilterSection(
            icon: FilterOptionsData.statusIcon,
            title: 'Project Status',
            child: AppSegmentedControl(
              labels: const ['Open Projects', 'Full / Completed'],
              selectedIndex: state.showOpen ? 0 : 1,
              onChanged: (i) => onChanged(state.copyWith(showOpen: i == 0)),
            ),
          ),

          MatchingOpportunitiesCard(
            count: matchingCount,
            summary: state.summary,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
