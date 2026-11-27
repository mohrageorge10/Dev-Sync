import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/headers/header.dart';
import 'package:devsync/core/shared/sheets/login_required_sheet.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:devsync/features/discover_project/data/repositories/discover_repository.dart';
import 'package:devsync/features/discover_project/presentation/screens/public_project_detail_screen.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/action_buttons_widget.dart';
import 'package:devsync/features/discover_project/presentation/widgets/available_hire_header.dart';
import 'package:devsync/features/discover_project/presentation/widgets/invite_project_picker_sheet.dart';
import 'package:devsync/features/discover_project/presentation/widgets/portfolio_project_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/profile_summary_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/public_cv_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/skills_section_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/social_links_section.dart';
import 'package:devsync/features/profile/presentation/widgets/github/github_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Public developer profile screen synced with DiscoverCubit.
class PublicProfileScreen extends StatelessWidget {
  final DeveloperModel developer;
  final bool isGuest;
  final bool showBottomBar;
  final Widget? customBottomBar;

  const PublicProfileScreen({
    super.key,
    required this.developer,
    this.isGuest = false,
    this.showBottomBar = true,
    this.customBottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return DiscoverCubitScope(
      child: _ProfileView(
        developer: developer,
        isGuest: isGuest,
        showBottomBar: showBottomBar,
        customBottomBar: customBottomBar,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final DeveloperModel developer;
  final bool isGuest;
  final bool showBottomBar;
  final Widget? customBottomBar;

  const _ProfileView({
    required this.developer,
    required this.isGuest,
    required this.showBottomBar,
    required this.customBottomBar,
  });

  void _onMessage(BuildContext context) {
    if (isGuest) {
      LoginRequiredSheet.show(
        context,
        message: 'Log in to message developers.',
      );
      return;
    }
    AppFeedback.show(
      context,
      message: 'Messaging ${developer.name} is coming soon.',
    );
  }

  void _onInvite(BuildContext context) {
    if (isGuest) {
      LoginRequiredSheet.show(
        context,
        message: 'Log in to invite developers to your project.',
      );
      return;
    }

    final cubit = context.read<DiscoverCubit>();
    final state = cubit.state;
    final eligible = state.ownedProjectsForDeveloper(developer);

    InviteProjectPickerSheet.show(
      context,
      developer: developer,
      eligibleProjects: eligible,
      hasAnyOwnedProjects: state.ownedProjects.isNotEmpty,
      onSelected: (project) {
        cubit.inviteDeveloper(developer: developer, project: project);
        AppFeedback.show(
          context,
          title: 'Invitation sent',
          message: 'Invited ${developer.name} to join "${project.title}".',
          type: AppFeedbackType.success,
        );
      },
    );
  }

  void _onBookmark(BuildContext context) {
    if (isGuest) {
      LoginRequiredSheet.show(context, message: 'Log in to save developers.');
      return;
    }
    context.read<DiscoverCubit>().toggleDeveloperSaved(developer.id);
  }

  // Copy profile URL to clipboard.
  Future<void> _onShare(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(text: 'https://devsync.app/${developer.username}'),
    );

    if (context.mounted) {
      AppFeedback.show(
        context,
        message: 'Profile link copied to clipboard.',
        type: AppFeedbackType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final skillCategories = developer.skillCategories;
    final totalValidated = skillCategories.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Developer Profile Detail',
        showActions: !isGuest,
        leading: Align(
          alignment: Alignment.center,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: c.textPrimary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<DiscoverCubit, DiscoverState>(
                buildWhen: (a, b) => a.savedDeveloperIds != b.savedDeveloperIds,
                builder: (context, state) => AvailableHireHeader(
                  isSaved: state.isDeveloperSaved(developer.id),
                  onSharePressed: () => _onShare(context),
                  onBookmarkPressed: () => _onBookmark(context),
                ),
              ),
              ProfileSummaryCard(developer: developer),
              Header(
                title: 'Technical & Soft Skills',
                text: '$totalValidated Validated',
              ),
              SkillsSectionCard(initialSkillsCategories: skillCategories),
              Header(
                title: 'Resume / CV',
                text: developer.hasCv ? 'PDF Attached' : 'Not uploaded',
              ),
              PublicCvCard(developer: developer),
              const Header(title: 'Connected Accounts', text: 'Verified links'),
              SocialLinksSection(items: developer.socialLinks),
              if (developer.githubAnalysis != null) ...[
                Header(
                  title: 'GitHub Activity',
                  text: '@${developer.githubAnalysis!.username}',
                ),
                GithubSummaryCard(analysis: developer.githubAnalysis!),
              ],
              FutureBuilder<List<PortfolioProjectData>>(
                future: ServiceLocator.isRegistered<DiscoverRepository>()
                    ? ServiceLocator.get<DiscoverRepository>()
                          .fetchDeveloperPublicProjects(developer.id)
                    : Future.value(const <PortfolioProjectData>[]),
                builder: (context, snapshot) {
                  final portfolio = snapshot.data ?? const [];
                  return Column(
                    spacing: 14,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Header(
                        title: 'Public Projects',
                        text:
                            snapshot.connectionState == ConnectionState.waiting
                            ? 'Loading...'
                            : '${portfolio.length} ${portfolio.length == 1 ? 'Project' : 'Projects'}',
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (portfolio.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: c.backgroundPrimary,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: c.border),
                          ),
                          child: Text(
                            'No public projects yet',
                            style: AppStyles.body13Secondary(context),
                          ),
                        )
                      else
                        for (final p in portfolio)
                          PortfolioProjectCard(
                            project: p,
                            onTap: () => Navigator.of(context).push(
                              AppPageRoute(
                                builder: (_) => PublicProjectDetailScreen(
                                  project: p,
                                  isGuest: isGuest,
                                ),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !showBottomBar
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.backgroundPrimary,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child:
                    customBottomBar ??
                    BlocBuilder<DiscoverCubit, DiscoverState>(
                      buildWhen: (a, b) =>
                          a.invitedDeveloperIds != b.invitedDeveloperIds,
                      builder: (context, state) => ActionButtonsWidget(
                        isInvited: state.isDeveloperInvited(developer.id),
                        onMessagePressed: () => _onMessage(context),
                        onInvitePressed: () => _onInvite(context),
                      ),
                    ),
              ),
            ),
    );
  }
}
