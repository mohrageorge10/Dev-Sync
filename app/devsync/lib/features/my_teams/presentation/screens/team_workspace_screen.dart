import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/team_widgets.dart';

// Overview hub for a selected team workspace
class TeamWorkspaceScreen extends StatelessWidget {
  final String teamId;
  const TeamWorkspaceScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final team = state.teamById(teamId);
    final p = state.progressOf(teamId);
    final pct = p.total == 0 ? 0.0 : p.done / p.total;
    final open = state.openTasksCount(teamId);
    final shown = team.members.take(3).map((m) => m.initials).toList();

    return Scaffold(
      appBar: const AppTopBar('Team Workspace'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Pill(team.role),
                const Spacer(),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: AppPalette.softBlue,
                      borderRadius: BorderRadius.circular(17)),
                  child: Icon(team.icon, size: 18, color: AppPalette.primary),
                ),
              ]),
              const SizedBox(height: 8),
              Text(team.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                    '${(pct * 100).round()}% Completed (${p.done}/${p.total} tasks)',
                    style:
                        const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
              ),
              const SizedBox(height: 4),
              ProgressLine(pct),
              const SizedBox(height: 12),
              Row(children: [
                AvatarStack(
                    initials: shown,
                    extra: (team.totalSeats - shown.length).clamp(0, 99),
                    size: 26),
                const SizedBox(width: 8),
                Text('+${team.openRoles.length} Open Seats',
                    style:
                        const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
                const Spacer(),
                Text('${team.members.length} Core Members',
                    style:
                        const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
              ]),
            ]),
          ),
          const SizedBox(height: 18),
          const SectionHeader('WORKSPACE HUB'),
          HubTile(
            icon: Icons.task_alt,
            title: 'Task Board',
            subtitle: '$open open • Sprint backlog & milestone tracking',
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
          const SizedBox(height: 18),
          AppCard(
            color: AppPalette.border.withAlpha(110),
            borderColor: Colors.transparent,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.settings_outlined, size: 16),
                SizedBox(width: 6),
                Text('Team Settings & Governance',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 12),
              _SettingRow(
                  label: 'Membership Permissions',
                  value: team.isOwner ? 'Invite Only' : 'Members'),
              const SizedBox(height: 8),
              _SettingRow(
                  label: 'Code Repository',
                  value: team.repoUrl,
                  link: true,
                  onTap: () => showSnack(context, team.repoUrl)),
              const SizedBox(height: 12),
              AppSecondaryButton(
                buttonText: 'Leave Team',
                leadingIcon: Icons.logout,
                onPressed: () => _confirmLeave(context, team.name, teamId),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Shows confirmation dialog before leaving the team
  Future<void> _confirmLeave(
      BuildContext context, String name, String teamId) async {
    final state = AppScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave team?'),
        content: Text('You will lose access to $name and its tasks.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave team',
                  style: TextStyle(color: AppPalette.danger))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      AppRouter.backToRoot(context);
      state.leaveTeam(teamId);
    }
  }
}

// Reusable key-value row for team settings
class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool link;
  final VoidCallback? onTap;
  const _SettingRow(
      {required this.label, required this.value, this.link = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppPalette.muted)),
      const Spacer(),
      GestureDetector(
        onTap: onTap,
        child: Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: link ? AppPalette.primary : AppPalette.text)),
      ),
    ]);
  }
}
