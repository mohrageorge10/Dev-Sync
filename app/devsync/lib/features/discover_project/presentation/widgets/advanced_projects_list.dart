import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/advanced_project.dart';
import 'package:devsync/features/discover_project/presentation/widgets/cancel_application_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// List of recommended projects on the home feed.
class AdvancedProjectsList extends StatelessWidget {
  const AdvancedProjectsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Column(
            children: [
              ProjectCardShimmer(),
              SizedBox(height: 12),
              ProjectCardShimmer(),
            ],
          );
        }

        final items = state.recommendedProjects;
        final cubit = context.read<DiscoverCubit>();

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No projects found',
                style: AppStyles.body13Secondary(context),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              AppFadeSlide(
                delay: Duration(milliseconds: 50 * i),
                child: AdvancedProject(
                  badgeText: items[i].type,
                  timeAgoText: items[i].createdAgo,
                  title: items[i].title,
                  description: items[i].description,
                  matchPercentageText: items[i].matchPercentageText,
                  matchReasonText: items[i].matchReason,
                  projectIcon: items[i].icon,
                  techStacks: items[i].tags,
                  membersText: items[i].membersFilledText,
                  isSaved: state.isProjectSaved(items[i].id),
                  isApplied: state.isProjectApplied(items[i].id),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.projectDetails,
                    arguments: items[i],
                  ),
                  onBookmarkPressed: () {
                    final wasSaved = state.isProjectSaved(items[i].id);
                    cubit.toggleProjectSaved(items[i].id);
                    AppFeedback.show(
                      context,
                      message: wasSaved
                          ? 'Removed "${items[i].title}" from saved.'
                          : 'Saved "${items[i].title}" to Saved.',
                      type: wasSaved
                          ? AppFeedbackType.info
                          : AppFeedbackType.success,
                    );
                  },
                  onQuickApplyPressed: () async {
                    final project = items[i];
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
                      message:
                          'Your request to join "${project.title}" was sent.',
                      type: AppFeedbackType.success,
                    );
                  },
                ),
              ),
              if (i != items.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}
