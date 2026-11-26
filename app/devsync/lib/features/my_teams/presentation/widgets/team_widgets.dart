import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import 'common.dart';

// Card displaying team overview, task counts, and member avatars.
class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.openTasks,
    required this.onOpen,
  });

  final Team team;
  final int openTasks;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shown = team.members.take(3).map((m) => m.initials).toList();
    final extra = team.totalSeats - shown.length;

    return AppCard(
      onTap: onOpen,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(team.icon, color: c.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.name, style: AppStyles.title15Bold(context)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 7, color: c.success),
                        const SizedBox(width: 4),
                        Text(
                          team.subtitle,
                          style: AppStyles.body11Secondary(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Pill(
                team.role,
                fg: team.isOwner ? c.primary : c.textSecondary,
                bg: team.isOwner ? c.subtleBlueSurface : c.surface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoStrip(
            icon: Icons.check_circle_outline,
            left: '$openTasks open tasks',
            right: team.sprint,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AvatarStack(
                initials: shown,
                extra: extra < 0 ? 0 : extra,
                size: 26,
              ),
              const Spacer(),
              Text(
                'Workspace',
                style: AppStyles.body12SemiBold(context, color: c.primary),
              ),
              Icon(Icons.chevron_right, size: 16, color: c.primary),
            ],
          ),
        ],
      ),
    );
  }
}

// List tile displaying member profile, role badge, handle, and optional Owner menu.
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    this.isMe = false,
    this.onManageTap,
  });

  final Member member;
  final bool isMe;
  final VoidCallback? onManageTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final role = member.effectiveRole;
    final roleFg = switch (role) {
      TeamRole.owner => c.primary,
      TeamRole.trackLeader => c.warning,
      TeamRole.member => c.textSecondary,
    };
    final roleBg = switch (role) {
      TeamRole.owner => c.subtleBlueSurface,
      TeamRole.trackLeader => c.subtle(c.warning),
      TeamRole.member => c.surface,
    };

    return AppCard(
      child: Row(
        children: [
          Avatar(member.initials, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      isMe ? '${member.name} (You)' : member.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.body13Bold(context),
                    ),
                    Pill(
                      member.roleBadgeLabel,
                      fg: roleFg,
                      bg: roleBg,
                      fontSize: 9.5,
                    ),
                    if (member.isOwner && member.alsoTrackLeader)
                      Pill(
                        member.leaderBadgeLabel,
                        fg: c.warning,
                        bg: c.subtle(c.warning),
                        fontSize: 9.5,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.role, style: AppStyles.body11Secondary(context)),
                const SizedBox(height: 2),
                Text(
                  '</> ${member.handle}',
                  style: AppStyles.body11Secondary(context),
                ),
              ],
            ),
          ),
          if (onManageTap != null)
            IconButton(
              onPressed: onManageTap,
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: c.textSecondary,
              ),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

// Card representing an open vacancy in the team.
class OpenRoleCard extends StatelessWidget {
  const OpenRoleCard({super.key, required this.role, required this.onFind});

  final OpenRole role;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 7, color: c.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(role.title, style: AppStyles.body13Bold(context)),
              ),
              const Pill('1 spot open', fontSize: 9.5),
            ],
          ),
          const SizedBox(height: 4),
          Text(role.description, style: AppStyles.body12Secondary(context)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(
                role.level,
                fg: c.textSecondary,
                bg: c.surface,
                icon: Icons.trending_up,
              ),
              Pill(
                role.hours,
                fg: c.textSecondary,
                bg: c.surface,
                icon: Icons.schedule,
              ),
              Pill(
                role.tech,
                fg: c.textSecondary,
                bg: c.surface,
                icon: Icons.storage,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            buttonText: 'Find Developers',
            trailingIcon: Icons.arrow_forward,
            isDisabled: false,
            onPressed: onFind,
          ),
        ],
      ),
    );
  }
}

// Navigation tile for workspace sub-sections.
class HubTile extends StatelessWidget {
  const HubTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(icon, color: c.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body13Bold(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppStyles.body11Secondary(context)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: c.textSecondary),
        ],
      ),
    );
  }
}
