import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/team_analytics_card.dart';
import '../widgets/team_widgets.dart';

// Overview hub for a selected team workspace with visual analytics.
class TeamWorkspaceScreen extends StatelessWidget {
  const TeamWorkspaceScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(teamId);
    if (team == null) {
      return Scaffold(
        backgroundColor: c.surface,
        appBar: const AppTopBar('Team Workspace'),
        body: Center(
          child: Text(
            'This team is no longer available.',
            style: AppStyles.body14Secondary(context),
          ),
        ),
      );
    }

    final p = state.progressOf(teamId);
    final pct = p.total == 0 ? 0.0 : p.done / p.total;
    final open = state.openTasksCount(teamId);
    final shown = team.members.take(3).map((m) => m.initials).toList();
    final isOwner = state.isOwnerOf(teamId);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar('Team Workspace'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(team.role),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Icon(team.icon, size: 18, color: c.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(team.name, style: AppStyles.h20(context)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(pct * 100).round()}% Completed (${p.done}/${p.total} tasks)',
                    style: AppStyles.body11Secondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                ProgressLine(pct),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AvatarStack(
                      initials: shown,
                      extra: (team.totalSeats - shown.length).clamp(0, 99),
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${team.openRoles.length} Open Seats',
                      style: AppStyles.body11Secondary(context),
                    ),
                    const Spacer(),
                    Text(
                      '${team.members.length} Core Members',
                      style: AppStyles.body11Secondary(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Visual project analytics (donut chart, KPIs, member workload).
          TeamAnalyticsCard(
            breakdown: state.statusBreakdown(teamId),
            overdueCount: state.overdueCount(teamId),
            workload: state.memberWorkload(teamId),
          ),

          const SizedBox(height: 18),
          const SectionHeader('WORKSPACE HUB'),
          HubTile(
            icon: Icons.task_alt,
            title: 'Task Board',
            subtitle: isOwner
                ? '$open open • Manage sprint tasks & approvals'
                : '$open assigned to you • Track & submit for review',
            onTap: () => AppRouter.toTaskBoard(context, team),
          ),
          const SizedBox(height: 10),
          HubTile(
            icon: Icons.groups_outlined,
            title: 'Team Members',
            subtitle:
                '${team.members.length} active contributors, ${team.openRoles.length} open roles',
            onTap: () => AppRouter.toMembers(context, team),
          ),
          if (isOwner) ...[
            const SizedBox(height: 10),
            HubTile(
              icon: Icons.tune_rounded,
              title: 'Team Settings',
              subtitle: 'Role permissions, workflow rules & workspace config',
              onTap: () => AppRouter.toTeamSettings(context, team),
            ),
          ],
          const SizedBox(height: 18),
          AppCard(
            color: c.backgroundPrimary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 16,
                      color: c.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Team Settings & Governance',
                      style: AppStyles.body13Bold(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SettingRow(
                  label: 'Membership Permissions',
                  value: team.settings.inviteOnly
                      ? 'Invite Only'
                      : 'Open for Applications',
                ),
                const SizedBox(height: 8),
                _SettingRow(
                  label: 'Code Repository',
                  value: team.repoUrl.replaceFirst(RegExp(r'^https?://'), ''),
                  link: true,
                  onTap: () => openExternalUrl(context, team.repoUrl),
                ),
                const SizedBox(height: 12),
                AppSecondaryButton(
                  buttonText: 'Leave Team',
                  leadingIcon: Icons.logout,
                  onPressed: () => _confirmLeave(context, team.name, teamId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shows confirmation dialog before leaving the team (Owner must transfer first if others remain).
  Future<void> _confirmLeave(
    BuildContext context,
    String name,
    String teamId,
  ) async {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(teamId);
    if (team != null &&
        state.isOwnerOf(teamId) &&
        team.members.any((m) => !m.isOwner)) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: c.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Transfer ownership first',
            style: AppStyles.title17Bold(ctx),
          ),
          content: Text(
            'As Project Owner, please transfer ownership to another member in Team Settings before leaving "$name".',
            style: AppStyles.body14Secondary(ctx),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: AppStyles.body14Secondary(ctx)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Team Settings',
                style: AppStyles.body14Bold(ctx, color: c.primary),
              ),
            ),
          ],
        ),
      );
      if (openSettings == true && context.mounted) {
        AppRouter.toTeamSettings(context, team);
      }
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Leave team?', style: AppStyles.title17Bold(ctx)),
        content: Text(
          'You will lose access to $name and its tasks.',
          style: AppStyles.body14Secondary(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppStyles.body14Secondary(ctx)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Leave team',
              style: AppStyles.body14Bold(ctx, color: c.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pop();
      await state.leaveTeam(teamId);
    }
  }
}

// Reusable key-value row for team settings.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    this.link = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool link;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Text(label, style: AppStyles.body12Secondary(context)),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.body12SemiBold(
                context,
                color: link ? c.primary : c.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
