import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/my_projects_screen/applied_tab_view.dart';
import '../widgets/my_projects_screen/drafted_project_card.dart';
import '../widgets/my_projects_screen/empty_view.dart';
import '../widgets/my_projects_screen/invited_project_card.dart';
import '../widgets/my_projects_screen/ongoing_tab_view.dart';
import '../widgets/my_projects_screen/previous_project_card.dart';
import 'invitation_details_screen.dart';
import 'project_overview_screen.dart';

// Main My Projects screen with Ongoing, Invited, and Previous tabs.
class MyProjectsScreen extends StatelessWidget {
  const MyProjectsScreen({super.key, this.embedded = false});

  final bool embedded;

  void _pushWithCubit(BuildContext context, Widget page) {
    final cubit = context.read<MyProjectsCubit>();
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }

  void _confirmDeleteDraft(
    BuildContext context,
    MyProjectsCubit cubit,
    String projectId,
    String projectName,
  ) {
    final c = context.colors;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete draft?', style: AppStyles.title17Bold(ctx)),
        content: Text(
          '"$projectName" will be permanently deleted.',
          style: AppStyles.body14Secondary(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppStyles.body14Secondary(ctx)),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteDraft(projectId);
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: AppStyles.body14Bold(ctx, color: c.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: c.backgroundPrimary,
        appBar: CustomAppBar(
          title: 'My Projects',
          leading: embedded
              ? const Align(alignment: Alignment.center, child: DevSyncLogo())
              : Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
        ),
        body: BlocConsumer<MyProjectsCubit, MyProjectsState>(
          listener: (context, state) {
            if (state is MyProjectsLoaded && state.message != null) {
              AppFeedback.show(
                context,
                message: state.message!,
                type: AppFeedbackType.success,
              );
            }
          },
          builder: (context, state) {
            if (state is MyProjectsLoading || state is MyProjectsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MyProjectsError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: AppStyles.body14Secondary(context),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      child: AppButton(
                        label: 'Retry',
                        onPressed: () =>
                            context.read<MyProjectsCubit>().loadData(),
                      ),
                    ),
                  ],
                ),
              );
            }

            final data = state as MyProjectsLoaded;
            final cubit = context.read<MyProjectsCubit>();
            final pendingInvitations = data.pendingInvitations;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: AppButton(
                    label: '+ Create New Project',
                    onPressed: () async {
                      await Navigator.of(context)
                          .pushNamed(AppRoutes.createProject);
                      if (context.mounted) cubit.loadData();
                    },
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: c.primary,
                  unselectedLabelColor: c.textSecondary,
                  indicatorColor: c.primary,
                  dividerColor: c.border,
                  labelStyle: AppStyles.body12Bold(context),
                  unselectedLabelStyle: AppStyles.body12Medium(context),
                  tabs: [
                    Tab(text: 'Ongoing (${data.ongoing.length})'),
                    Tab(text: 'Applied (${data.myApplications.length})'),
                    Tab(text: 'Invited (${data.pendingInvitations.length})'),
                    Tab(text: 'Drafted (${data.drafted.length})'),
                    Tab(text: 'Previous (${data.previous.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      OngoingTabView(
                        projects: data.ongoing,
                        onRefresh: cubit.loadData,
                        onTapProject: (p) => _pushWithCubit(
                          context,
                          ProjectOverviewScreen(project: p),
                        ),
                      ),
                      AppliedTabView(
                        applications: data.myApplications,
                        onRefresh: cubit.loadData,
                        onWithdraw: cubit.withdrawApplication,
                        onOpenWorkspace: (app) {
                          if (ServiceLocator.isRegistered<TeamsController>()) {
                            final team = ServiceLocator.get<TeamsController>()
                                .teams
                                .where(
                                  (t) =>
                                      t.id == app.projectId ||
                                      t.name.toLowerCase() ==
                                          app.projectTitle.toLowerCase(),
                                )
                                .firstOrNull;
                            if (team != null) {
                              AppRouter.toWorkspace(context, team);
                              return;
                            }
                          }
                          Navigator.of(context).pushNamed(AppRoutes.myTeams);
                        },
                      ),
                      RefreshIndicator(
                        onRefresh: cubit.loadData,
                        child: pendingInvitations.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  EmptyView('No pending invitations'),
                                ],
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  96,
                                ),
                                children: pendingInvitations
                                    .map(
                                      (i) => InvitedProjectCard(
                                        invitation: i,
                                        onView: () => _pushWithCubit(
                                          context,
                                          InvitationDetailsScreen(
                                            invitation: i,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      RefreshIndicator(
                        onRefresh: cubit.loadData,
                        child: data.drafted.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  EmptyView('No saved drafts'),
                                ],
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  96,
                                ),
                                children: data.drafted
                                    .map(
                                      (p) => DraftedProjectCard(
                                        project: p,
                                        onTap: () => _pushWithCubit(
                                          context,
                                          ProjectOverviewScreen(project: p),
                                        ),
                                        onPublish: () =>
                                            cubit.publishDraft(p.id),
                                        onDelete: () => _confirmDeleteDraft(
                                          context,
                                          cubit,
                                          p.id,
                                          p.name,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                      RefreshIndicator(
                        onRefresh: cubit.loadData,
                        child: data.previous.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  SizedBox(height: 120),
                                  EmptyView('No previous projects'),
                                ],
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  96,
                                ),
                                children: data.previous
                                    .map(
                                      (p) => PreviousProjectCard(
                                        project: p,
                                        onView: () => _pushWithCubit(
                                          context,
                                          ProjectOverviewScreen(project: p),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
