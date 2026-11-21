import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import 'common.dart';

// Card displaying team overview, task counts, and member avatars
class TeamCard extends StatelessWidget {
  final Team team;
  final int openTasks;
  final VoidCallback onOpen;
  const TeamCard(
      {super.key,
      required this.team,
      required this.openTasks,
      required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final shown = team.members.take(3).map((m) => m.initials).toList();
    final extra = team.totalSeats - shown.length;
    return AppCard(
      onTap: onOpen,
      child: Column(children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppPalette.softBlue,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(team.icon, color: AppPalette.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(team.name,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.circle, size: 7, color: AppPalette.success),
                const SizedBox(width: 4),
                Text(team.subtitle,
                    style:
                        const TextStyle(fontSize: 11, color: AppPalette.muted)),
              ]),
            ]),
          ),
          Pill(team.role,
              fg: team.isOwner ? AppPalette.primary : AppPalette.muted,
              bg: team.isOwner ? AppPalette.softBlue : AppPalette.fieldBg),
        ]),
        const SizedBox(height: 12),
        InfoStrip(
            icon: Icons.check_circle_outline,
            left: '$openTasks open tasks',
            right: team.sprint),
        const SizedBox(height: 12),
        Row(children: [
          AvatarStack(initials: shown, extra: extra < 0 ? 0 : extra, size: 26),
          const Spacer(),
          const Text('Workspace',
              style: TextStyle(
                  fontSize: 11.5,
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w600)),
          const Icon(Icons.chevron_right, size: 16, color: AppPalette.primary),
        ]),
      ]),
    );
  }
}

// List tile displaying member profile, role, and handle
class MemberTile extends StatelessWidget {
  final Member member;
  final bool isMe;
  const MemberTile({super.key, required this.member, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(children: [
        Avatar(member.initials, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(isMe ? '${member.name} (You)' : member.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 6),
              Pill(member.isOwner ? 'Owner' : 'Member',
                  fg: member.isOwner ? AppPalette.primary : AppPalette.muted,
                  bg: member.isOwner ? AppPalette.softBlue : AppPalette.fieldBg,
                  fontSize: 9.5),
            ]),
            const SizedBox(height: 2),
            Text(member.role,
                style:
                    const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
            const SizedBox(height: 2),
            Text('</> ${member.handle}',
                style:
                    const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
          ]),
        ),
      ]),
    );
  }
}

// Card representing an open vacancy in the team
class OpenRoleCard extends StatelessWidget {
  final OpenRole role;
  final VoidCallback onFind;
  const OpenRoleCard({super.key, required this.role, required this.onFind});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.circle, size: 7, color: AppPalette.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(role.title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          const Pill('1 spot open', fontSize: 9.5),
        ]),
        const SizedBox(height: 4),
        Text(role.description,
            style: const TextStyle(fontSize: 11, color: AppPalette.muted)),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          Pill(role.level,
              fg: AppPalette.muted,
              bg: AppPalette.fieldBg,
              icon: Icons.trending_up),
          Pill(role.hours,
              fg: AppPalette.muted, bg: AppPalette.fieldBg, icon: Icons.schedule),
          Pill(role.tech,
              fg: AppPalette.muted, bg: AppPalette.fieldBg, icon: Icons.storage),
        ]),
        const SizedBox(height: 12),
        AppPrimaryButton(
          buttonText: 'Find Developers',
          trailingIcon: Icons.arrow_forward,
          isDisabled: false,
          onPressed: onFind,
        ),
      ]),
    );
  }
}

// Navigation tile for workspace sub-sections
class HubTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const HubTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppPalette.softBlue,
              borderRadius: BorderRadius.circular(19)),
          child: Icon(icon, color: AppPalette.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle,
                style:
                    const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
          ]),
        ),
        const Icon(Icons.chevron_right, size: 18, color: AppPalette.muted),
      ]),
    );
  }
}

// Bottom navigation bar for the application
class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.index, required this.onTap});

  static const _items = <(IconData, String)>[
    (Icons.explore_outlined, 'Discover'),
    (Icons.people_outline, 'Community'),
    (Icons.folder_copy_outlined, 'My Teams'),
    (Icons.chat_bubble_outline, 'Messages'),
    (Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppPalette.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_items[i].$1,
                            size: 22,
                            color: i == index
                                ? AppPalette.primary
                                : AppPalette.muted),
                        const SizedBox(height: 3),
                        Text(_items[i].$2,
                            style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: i == index
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i == index
                                    ? AppPalette.primary
                                    : AppPalette.muted)),
                      ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
