import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/cancel_application_dialog.dart';
import 'package:devsync/features/discover_project/presentation/widgets/discover_list.dart';
import 'package:devsync/features/discover_project/presentation/widgets/project_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/projects_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Projects tab content in the discover screen.
class ProjectsContent extends StatelessWidget {
  const ProjectsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.separated(
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => const ProjectCardShimmer(),
          );
        }

        final cubit = context.read<DiscoverCubit>();

        return DiscoverList<ProjectModel>(
          items: state.projects,
          empty: ProjectsEmptyState(
            searchQuery: state.searchQuery,
            onBrowseAll: cubit.resetAll,
            onClearFilters: cubit.clearFilters,
          ),
          itemBuilder: (_, project) => AppFadeSlide(
            child: ProjectCard(
              project: project,
              isSaved: state.isProjectSaved(project.id),
              isApplied: state.isProjectApplied(project.id),
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.projectDetails,
                arguments: project,
              ),
              onApply: () async {
                if (state.isProjectApplied(project.id)) {
                  final confirmed = await showCancelApplicationDialog(
                    context,
                    projectTitle: project.title,
                  );
                  if (!confirmed || !context.mounted) return;
                  await cubit.cancelApplication(project.id);
                  if (!context.mounted) return;
                  AppFeedback.show(
                    context,
                    title: 'Application cancelled',
                    message:
                        'Withdrew your request to join "${project.title}".',
                    type: AppFeedbackType.info,
                  );
                  return;
                }
                cubit.applyToProject(project.id);
                AppFeedback.show(
                  context,
                  title: 'Application sent',
                  message: 'Your request to join "${project.title}" was sent.',
                  type: AppFeedbackType.success,
                );
              },
              onBookmark: () {
                final wasSaved = state.isProjectSaved(project.id);
                cubit.toggleProjectSaved(project.id);
                AppFeedback.show(
                  context,
                  message: wasSaved
                      ? 'Removed "${project.title}" from saved.'
                      : 'Saved "${project.title}" to Saved.',
                  type: wasSaved
                      ? AppFeedbackType.info
                      : AppFeedbackType.success,
                );
              },
            ),
          ),
        );
      },
    );
  }
}