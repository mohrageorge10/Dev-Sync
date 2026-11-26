import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/developer_model.dart';
import '../../data/models/project_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/project_overview_screen/candidate_pipeline_card.dart';
import '../widgets/project_overview_screen/project_header_card.dart';
import '../widgets/project_overview_screen/project_repo_rules_card.dart';
import '../widgets/project_overview_screen/team_info_card.dart';
import '../widgets/user_avatar.dart';
import 'edit_project_screen.dart';
import 'edit_repo_rules_screen.dart';
import 'incoming_requests_screen.dart';
import 'invite_developer_screen.dart';

// Project overview screen showing details, repo/Git rules, workspace link, and owner actions.
class ProjectOverviewScreen extends StatelessWidget {
  const ProjectOverviewScreen({super.key, required this.project});

  final ProjectModel project;

  void _pushWithCubit(BuildContext context, Widget page) {
    final cubit = context.read<MyProjectsCubit>();
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => BlocProvider.value(value: cubit, child: page),
      ),
    );
  }

  void _openTeamWorkspace(BuildContext context, ProjectModel current) {
    if (ServiceLocator.isRegistered<TeamsController>()) {
      final teamsCtrl = ServiceLocator.get<TeamsController>();
      final match = teamsCtrl.teams
          .where(
            (t) =>
                t.id == current.id ||
                t.name.toLowerCase() == current.name.toLowerCase(),
          )
          .firstOrNull;
      if (match != null) {
        AppRouter.toWorkspace(context, match);
        return;
      }
    }
    Navigator.of(context).pushNamed(AppRoutes.myTeams);
  }

  Future<void> _pickDeveloperToInvite(BuildContext context) async {
    final c = context.colors;
    final devs = context.read<MyProjectsCubit>().developers;
    if (devs.isEmpty) {
      Navigator.of(context).pushNamed(AppRoutes.discoverSearch, arguments: 1);
      return;
    }

    final selected = await showModalBottomSheet<DeveloperModel?>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Choose a Developer to Invite',
                style: AppStyles.title16Bold(ctx),
              ),
            ),
            for (final d in devs)
              ListTile(
                leading: UserAvatar(name: d.name, radius: 20),
                title: Text(d.name, style: AppStyles.body14Bold(ctx)),
                subtitle: Text(d.title, style: AppStyles.body12Secondary(ctx)),
                trailing: Text(
                  '${d.fitPercent}% Fit',
                  style: AppStyles.body12Bold(ctx, color: c.success),
                ),
                onTap: () => Navigator.pop(ctx, d),
              ),
            Divider(color: c.border),
            ListTile(
              leading: Icon(Icons.search_rounded, color: c.primary),
              title: Text(
                'Browse All Developers',
                style: AppStyles.body14Bold(ctx, color: c.primary),
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context)
                    .pushNamed(AppRoutes.discoverSearch, arguments: 1);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      _pushWithCubit(context, InviteDeveloperScreen(developer: selected));
    }
  }

  void _confirmArchive(BuildContext context, ProjectModel current) {
    final c = context.colors;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Archive project?',
          style: AppStyles.title17Bold(dialogContext),
        ),
        content: Text(
          'The project will become read-only and move to Previous.',
          style: AppStyles.body14Secondary(dialogContext),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppStyles.body14Secondary(dialogContext),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<MyProjectsCubit>().archiveProject(current.id);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(
              'Archive',
              style: AppStyles.body14Bold(dialogContext, color: c.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocBuilder<MyProjectsCubit, MyProjectsState>(
      builder: (context, state) {
        final data = state is MyProjectsLoaded ? state : null;
        final current =
            data?.projects.where((p) => p.id == project.id).firstOrNull ??
            project;
        final isOngoing = current.type == ProjectType.ongoing;
        final canManage = current.isOwner && isOngoing;
        final canEditProject =
            current.isOwner && current.type != ProjectType.previous;
        final pendingCount =
            data?.pendingApplicantsFor(current.id).length ?? 0;

        return Scaffold(
          backgroundColor: c.surface,
          appBar: CustomAppBar(
            title: 'Project Overview',
            showActions: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            extraActions: [
              if (canEditProject)
                IconButton(
                  tooltip: 'Edit project',
                  icon: Icon(Icons.edit_outlined, size: 20, color: c.primary),
                  onPressed: () => _pushWithCubit(
                    context,
                    EditProjectScreen(project: current),
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProjectHeaderCard(project: current),
              ProjectRepoRulesCard(
                project: current,
                canEdit: canEditProject,
                onEdit: () => _pushWithCubit(
                  context,
                  EditRepoRulesScreen(project: current),
                ),
              ),
              TeamInfoCard(project: current),
              if (isOngoing) ...[
                AppButton(
                  label: 'Open Team Workspace',
                  outlined: true,
                  color: c.primary,
                  onPressed: () => _openTeamWorkspace(context, current),
                ),
                const SizedBox(height: 12),
              ],
              if (canManage) ...[
                CandidatePipelineCard(
                  incomingRequests: pendingCount,
                  sentInvitations: data?.sentInvitations ?? 0,
                  onReview: () => _pushWithCubit(
                    context,
                    IncomingRequestsScreen(projectId: current.id),
                  ),
                ),
                const SizedBox(height: 4),
                AppButton(
                  label: 'Invite Developers',
                  onPressed: () => _pickDeveloperToInvite(context),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Archive Project',
                  outlined: true,
                  color: c.error,
                  onPressed: () => _confirmArchive(context, current),
                ),
              ] else if (current.isOwner &&
                  current.type == ProjectType.draft) ...[
                const SizedBox(height: 4),
                AppButton(
                  label: 'Publish Draft',
                  onPressed: () {
                    context.read<MyProjectsCubit>().publishDraft(current.id);
                    Navigator.pop(context);
                  },
                ),
              ] else if (current.isOwner &&
                  current.type == ProjectType.previous) ...[
                const SizedBox(height: 4),
                AppButton(
                  label: 'Restore Project',
                  onPressed: () {
                    context.read<MyProjectsCubit>().restoreProject(current.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
