import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/developer_link_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Recommended developers list on the home feed.
class RecommendedDevelopersSection extends StatelessWidget {
  const RecommendedDevelopersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Column(
            children: [
              DeveloperCardShimmer(),
              SizedBox(height: 16),
              DeveloperCardShimmer(),
            ],
          );
        }

        final items = state.recommendedDevelopers;

        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No developers found',
                style: AppStyles.body13Secondary(context),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppFadeSlide(
                  delay: Duration(milliseconds: 50 * i),
                  child: DeveloperLinkCard(developer: items[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}
