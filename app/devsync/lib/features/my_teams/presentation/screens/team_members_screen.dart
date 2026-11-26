import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/team_widgets.dart';
import '../widgets/track_leader_picker_dialog.dart';

// Screen displaying active team members, role management (Owner), and open roles.
class TeamMembersScreen extends StatelessWidget {
  const TeamMembersScreen({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(teamId);
    if (team == null) {
      return const Scaffold(
        appBar: AppTopBar('Team Members'),
        body: Center(child: Text('Team not found')),
      );
    }

    final isOwner = state.isOwnerOf(teamId);
    final canInvite = state.canInviteMembers(teamId);
    final filled = team.members.length;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar('Team Members'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle, size: 7, color: c.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${team.name} Squad',
                      style: AppStyles.body11Secondary(context),
                    ),
                    const Spacer(),
                    Pill('$filled of ${team.totalSeats} filled', fontSize: 9.5),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Active Contributors & Open Roles',
                  style: AppStyles.title16Bold(context),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwner
                      ? 'Tap the menu on any member to change their role (Track Leader / Member) or manage access.'
                      : 'Review active contributors, roles, and open team capacity.',
                  style: AppStyles.body11Secondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            'Active Members',
            badge: Pill('$filled', fontSize: 9.5),
            trailing: 'Core Team',
          ),
          for (final m in team.members) ...[
            MemberTile(
              member: m,
              isMe: m.id == state.me.id,
              onManageTap: isOwner
                  ? () => m.isOwner
                        ? _showOwnerSelfRoleSheet(context, state, team, m)
                        : _showManageMemberSheet(context, state, team, m)
                  : null,
            ),
            const SizedBox(height: 10),
          ],
          if (team.openRoles.isNotEmpty && canInvite) ...[
            const SizedBox(height: 6),
            SectionHeader(
              'Open Roles',
              badge: Pill('${team.openRoles.length} Openings', fontSize: 9.5),
              trailing: 'Scouting View',
            ),
            for (final r in team.openRoles) ...[
              OpenRoleCard(
                role: r,
                onFind: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.discoverSearch, arguments: 1),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  // Owner self-role sheet: assign or remove Owner's project-track leader badge.
  Future<void> _showOwnerSelfRoleSheet(
    BuildContext context,
    TeamsController state,
    Team team,
    Member owner,
  ) async {
    final c = context.colors;
    final alsoLeader = owner.alsoTrackLeader;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Avatar(owner.initials, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${owner.name} (You)', style: AppStyles.body14Bold(ctx)),
                        Text(
                          alsoLeader
                              ? 'Project Owner & ${owner.leaderBadgeLabel}'
                              : 'Project Owner',
                          style: AppStyles.body11Secondary(ctx),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: c.border),
            ListTile(
              leading: Icon(Icons.workspace_premium_outlined, color: c.warning),
              title: Text(
                alsoLeader ? 'Change Leader Track' : 'Also Act as Track Leader',
                style: AppStyles.body14Primary(ctx),
              ),
              subtitle: Text(
                'Pick one of this project\'s tracks to lead while staying Owner.',
                style: AppStyles.body11Secondary(ctx),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await showTrackLeaderPickerDialog(
                  context,
                  memberName: 'you',
                  projectTracks: team.availableTracks,
                  currentTrack: owner.leaderTrack,
                );
                if (picked == null || !context.mounted) return;
                await state.toggleOwnerTrackLeader(teamId, leaderTrack: picked);
                if (!context.mounted) return;
                final label = picked.isEmpty ? 'Track Leader' : '$picked Leader';
                showSnack(
                  context,
                  'You are now Project Owner & $label',
                  type: AppFeedbackType.success,
                );
              },
            ),
            if (alsoLeader)
              ListTile(
                leading: Icon(Icons.remove_circle_outline, color: c.textSecondary),
                title: Text(
                  'Remove ${owner.leaderBadgeLabel} Badge',
                  style: AppStyles.body14Primary(ctx),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  state.toggleOwnerTrackLeader(teamId);
                  showSnack(
                    context,
                    'Removed ${owner.leaderBadgeLabel} badge',
                    type: AppFeedbackType.success,
                  );
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Owner bottom sheet to assign a project track leader role, demote, or remove a member.
  Future<void> _showManageMemberSheet(
    BuildContext context,
    TeamsController state,
    Team team,
    Member member,
  ) async {
    final c = context.colors;
    final isLeader = member.effectiveRole == TeamRole.trackLeader;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Avatar(member.initials, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.name, style: AppStyles.body14Bold(ctx)),
                        Text(
                          member.roleBadgeLabel,
                          style: AppStyles.body11Secondary(ctx),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: c.border),
            ListTile(
              leading: Icon(Icons.workspace_premium_outlined, color: c.primary),
              title: Text(
                isLeader ? 'Change Leader Track' : 'Promote to Track Leader',
                style: AppStyles.body14Primary(ctx),
              ),
              subtitle: Text(
                'Assign a specific track from this project (e.g. Flutter, Backend).',
                style: AppStyles.body11Secondary(ctx),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await showTrackLeaderPickerDialog(
                  context,
                  memberName: member.name,
                  projectTracks: team.availableTracks,
                  currentTrack: member.leaderTrack,
                );
                if (picked == null || !context.mounted) return;
                await state.setMemberRole(
                  teamId,
                  member.id,
                  TeamRole.trackLeader,
                  leaderTrack: picked,
                );
                if (!context.mounted) return;
                final label = picked.isEmpty ? 'Track Leader' : '$picked Leader';
                showSnack(
                  context,
                  '${member.name} is now $label',
                  type: AppFeedbackType.success,
                );
              },
            ),
            if (isLeader)
              ListTile(
                leading: Icon(Icons.person_outline, color: c.textSecondary),
                title: Text(
                  'Set as Member',
                  style: AppStyles.body14Primary(ctx),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  state.setMemberRole(teamId, member.id, TeamRole.member);
                  showSnack(
                    context,
                    '${member.name} is now Member',
                    type: AppFeedbackType.success,
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.person_remove_outlined, color: c.error),
              title: Text(
                'Remove from Team',
                style: AppStyles.body14Bold(ctx, color: c.error),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    backgroundColor: c.backgroundPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    title: Text(
                      'Remove ${member.name}?',
                      style: AppStyles.title17Bold(dCtx),
                    ),
                    content: Text(
                      'Their assigned tasks will become unassigned.',
                      style: AppStyles.body14Secondary(dCtx),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: Text(
                          'Cancel',
                          style: AppStyles.body14Secondary(dCtx),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        child: Text(
                          'Remove',
                          style: AppStyles.body14Bold(dCtx, color: c.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await state.removeMember(teamId, member.id);
                  if (context.mounted) {
                    showSnack(context, 'Removed ${member.name} from team');
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
