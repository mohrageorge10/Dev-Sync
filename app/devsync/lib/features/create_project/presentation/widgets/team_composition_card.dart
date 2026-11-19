import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_state.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';

// Team composition summary card.
class TeamCompositionCard extends StatelessWidget {
  const TeamCompositionCard({
    super.key,
    required this.team,
    this.ownerTrack = UserTrack.mobile,
  });

  final TeamState team;
  final UserTrack ownerTrack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final openSeats = team.totalPeople;
    final totalSize = 1 + openSeats;
    final invited = team.pendingInvites;
    final ready = team.tracks.isNotEmpty;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and status.
          Row(
            children: [
              Text('Team composition', style: AppStyles.body11Secondary(context)),
              const Spacer(),
              Text(
                ready ? 'Ready for review' : 'Add a track',
                style: AppStyles.body11Bold(
                  context,
                  color: ready ? c.primary : c.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Total headcount.
          Row(
            children: [
              Text(
                'Total team size (incl. you)',
                style: AppStyles.body13Bold(context),
              ),
              const Spacer(),
              Text('$totalSize members', style: AppStyles.body13Bold(context)),
            ],
          ),
          const SizedBox(height: 8),

          // Filled + invited progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalSize == 0 ? 0 : (1 + invited) / totalSize,
              minHeight: 6,
              color: c.primary,
              backgroundColor: c.secondarySurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1 filled (You · ${ownerTrack.label}) · $invited invited · ${openSeats - invited} open spots',
            style: AppStyles.caption10Secondary(context),
          ),
          const SizedBox(height: 8),

          // Quick stats row.
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _Stat(Icons.person_pin_circle_outlined, 'Owner: ${ownerTrack.label}'),
              _Stat(Icons.circle, '${team.tracks.length} needed tracks'),
              _Stat(Icons.mail_outline, '$invited invites queued'),
              _Stat(Icons.auto_awesome, '${team.distinctSkills} skills targeted'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: c.primary),
        const SizedBox(width: 4),
        Text(text, style: AppStyles.caption10Secondary(context)),
      ],
    );
  }
}
