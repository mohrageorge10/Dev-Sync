import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/shared/cards/app_project_card.dart';
import 'package:devsync/core/shared/sheets/login_required_sheet.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Curated projects section for guest mode powered by DiscoverCubit.
class CuratedProjectsSection extends StatelessWidget {
  const CuratedProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      buildWhen: (a, b) =>
          a.isLoading != b.isLoading ||
          a.allProjects != b.allProjects ||
          a.guestSelectedSkill != b.guestSelectedSkill ||
          a.guestSearchQuery != b.guestSearchQuery,
      builder: (context, state) {
        if (state.isLoading) {
          return const Column(
            children: [
              ProjectCardShimmer(),
              SizedBox(height: 16),
              ProjectCardShimmer(),
            ],
          );
        }

        final items = state.guestProjects;

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
                child: AppProjectCard(
                  title: items[i].title,
                  description: items[i].description,
                  skills: items[i].tags,
                  members: items[i].members,
                  capacity: items[i].maxMembers,
                  isRealWorld: items[i].isRealWorld,
                  matchPercent: items[i].matchPercent,
                  onViewProject: () => LoginRequiredSheet.show(
                    context,
                    message: 'Log in to view project details and apply.',
                  ),
                ),
              ),
              if (i != items.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}
