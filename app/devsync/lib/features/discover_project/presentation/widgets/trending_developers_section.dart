import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/animations/app_shimmer.dart';
import 'package:devsync/core/shared/sheets/login_required_sheet.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/developer_link_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Trending developers list for guest mode powered by DiscoverCubit.
class TrendingDevelopersSection extends StatelessWidget {
  const TrendingDevelopersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      buildWhen: (a, b) =>
          a.isLoading != b.isLoading ||
          a.allDevelopers != b.allDevelopers ||
          a.guestSelectedSkill != b.guestSelectedSkill ||
          a.guestSearchQuery != b.guestSearchQuery,
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

        final items = state.guestDevelopers;

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
                  child: DeveloperLinkCard(
                    developer: items[i],
                    isGuest: true,
                    onConnect: () => LoginRequiredSheet.show(
                      context,
                      message: 'Log in to connect with developers.',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
