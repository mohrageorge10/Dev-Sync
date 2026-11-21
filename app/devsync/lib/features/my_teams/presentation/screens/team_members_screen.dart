import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../widgets/common.dart';
import '../widgets/team_widgets.dart';

// Screen displaying active team members and open roles
class TeamMembersScreen extends StatelessWidget {
  final String teamId;
  const TeamMembersScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final team = state.teamById(teamId);
    final filled = team.members.length;

    return Scaffold(
      appBar: const AppTopBar('Team Members'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.circle, size: 7, color: AppPalette.primary),
                const SizedBox(width: 6),
                Text('${team.name} Squad',
                    style:
                        const TextStyle(fontSize: 11, color: AppPalette.muted)),
                const Spacer(),
                Pill('$filled of ${team.totalSeats} filled', fontSize: 9.5),
              ]),
              const SizedBox(height: 10),
              const Text('Active Contributors & Open Roles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                  'Manage technical ownership, review assigned domains, and scout contributors for vacant capacity.',
                  style: TextStyle(fontSize: 10.5, color: AppPalette.muted)),
            ]),
          ),
          const SizedBox(height: 16),
          SectionHeader('Active Members',
              badge: Pill('$filled', fontSize: 9.5), trailing: 'Core Team'),
          for (final m in team.members) ...[
            MemberTile(member: m, isMe: m.id == state.me.id),
            const SizedBox(height: 10),
          ],
          if (team.openRoles.isNotEmpty) ...[
            const SizedBox(height: 6),
            SectionHeader('Open Roles',
                badge: Pill('${team.openRoles.length} Openings', fontSize: 9.5),
                trailing: 'Owner Scouting View'),
            for (final r in team.openRoles) ...[
              OpenRoleCard(
                role: r,
                onFind: () =>
                    showSnack(context, 'Searching developers for ${r.title}…'),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
