import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/headers/header.dart';
import 'package:devsync/core/shared/input_fields/app_search_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/curated_projects_section.dart';
import 'package:devsync/features/discover_project/presentation/widgets/guest_mode_section.dart';
import 'package:devsync/features/discover_project/presentation/widgets/login_prompt_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/tech_stack_filter_list.dart';
import 'package:devsync/features/discover_project/presentation/widgets/trending_developers_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Guest mode discover home screen powered by DiscoverCubit.
class DiscoverHomeScreen extends StatelessWidget {
  const DiscoverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoverCubitScope(child: _DiscoverGuestView());
  }
}

class _DiscoverGuestView extends StatelessWidget {
  const _DiscoverGuestView();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<DiscoverCubit>();

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const CustomAppBar(
        title: 'DevSync',
        showActions: false,
        leading: Align(alignment: Alignment.center, child: DevSyncLogo()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GuestModeSection(),
              Text(
                'Discover open-source\ndeveloper collaborations',
                style: AppStyles.h28(context),
              ),
              LoginPromptCard(
                onLoginPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
                onCreateAccountPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.createAccount),
              ),
              AppSearchField(
                hintText: 'Filter by tech stack or role (e.g. Flutter, React)',
                prefixIcon: Icon(Icons.search, color: c.textSecondary),
                onChanged: cubit.searchGuest,
              ),
              BlocBuilder<DiscoverCubit, DiscoverState>(
                buildWhen: (a, b) =>
                    a.guestSelectedSkill != b.guestSelectedSkill,
                builder: (context, state) => TechStackFilterList(
                  selected: state.guestSelectedSkill,
                  onSelected: cubit.setGuestSkill,
                ),
              ),
              const SizedBox(height: 3),
              const Header(title: 'Curated Projects', text: 'TRENDING'),
              const CuratedProjectsSection(),
              const Header(title: 'Trending Developers', text: 'See All'),
              const TrendingDevelopersSection(),
            ],
          ),
        ),
      ),
    );
  }
}
