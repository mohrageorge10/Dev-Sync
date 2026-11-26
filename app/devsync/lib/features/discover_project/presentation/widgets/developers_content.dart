import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/developer_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/discover_list.dart';
import 'package:devsync/features/discover_project/presentation/widgets/end_of_list_message.dart';
import 'package:devsync/features/discover_project/presentation/widgets/projects_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Developers tab content in the discover screen.
class DevelopersContent extends StatelessWidget {
  const DevelopersContent({super.key});

  void _openProfile(BuildContext context, DeveloperModel developer) {
    Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: developer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.separated(
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const DeveloperCardShimmer(),
          );
        }

        final cubit = context.read<DiscoverCubit>();

        return DiscoverList<DeveloperModel>(
          items: state.developers,
          footer: const EndOfListMessage(),
          empty: ProjectsEmptyState(
            entityName: 'developers',
            searchQuery: state.searchQuery,
            onBrowseAll: cubit.resetAll,
            onClearFilters: cubit.clearFilters,
          ),
          itemBuilder: (_, developer) => AppFadeSlide(
            child: DeveloperCard(
              developer: developer,
              isSaved: state.isDeveloperSaved(developer.id),
              onViewProfile: () => _openProfile(context, developer),
              onBookmark: () => cubit.toggleDeveloperSaved(developer.id),
            ),
          ),
        );
      },
    );
  }
}
