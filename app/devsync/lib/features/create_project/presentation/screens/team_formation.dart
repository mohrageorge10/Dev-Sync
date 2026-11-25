import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/invite_card.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:devsync/features/create_project/presentation/widgets/team_composition_card.dart';
import 'package:devsync/features/create_project/presentation/widgets/track_card.dart';
import 'package:devsync/features/create_project/presentation/widgets/track_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 2: Team formation screen.
class TeamFormationScreen extends StatelessWidget {
  const TeamFormationScreen({
    super.key,
    this.onNext,
    this.onBack,
    this.embedded = false,
  });

  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final team = context.watch<TeamCubit>().state;
    final draft = context.watch<DraftCubit>().state.draft;
    final notifier = context.read<TeamCubit>();
    final suggestions = notifier.suggestedTracks(draft);
    final warnings = notifier.warnings(draft);
    final empty = team.tracks.isEmpty;

    final body = Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              // Header.
              Text(
                'TRACK CONFIGURATION',
                style: AppStyles.overline9Bold(context),
              ),
              const SizedBox(height: 4),
              Text('Build your team', style: AppStyles.h1(context)),
              const SizedBox(height: 4),
              Text(
                'You occupy 1 seat in your track. Add the open tracks and headcount needed from teammates.',
                style: AppStyles.body12Secondary(context),
              ),
              const SizedBox(height: 14),

              // Owner seat card.
              SoftCard(
                color: c.subtleBlueSurface,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.backgroundPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        draft.ownerTrack.icon,
                        size: 20,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You (Project Owner)',
                            style: AppStyles.body13Bold(context),
                          ),
                          Text(
                            'Track: ${draft.ownerTrack.label} · 1 filled seat',
                            style: AppStyles.body11Secondary(context),
                          ),
                        ],
                      ),
                    ),
                    AppBadge.success(context, '1/1 Filled'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Empty state or active track list.
              if (empty)
                SoftCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: c.subtleBlueSurface,
                        child: Icon(Icons.groups_2_outlined, color: c.primary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No open teammate tracks yet',
                        style: AppStyles.body13Bold(context),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add the tracks your project needs and define team sizes.',
                        textAlign: TextAlign.center,
                        style: AppStyles.body11Secondary(context),
                      ),
                      const SizedBox(height: 14),
                      AppPrimaryButton(
                        buttonText: 'Add first needed track',
                        leadingIcon: Icons.add_circle_outline,
                        isDisabled: false,
                        onPressed: () => TrackPickerSheet.show(context),
                      ),
                    ],
                  ),
                )
              else ...[
                for (final t in team.tracks) ...[
                  TrackCard(track: t),
                  const SizedBox(height: 12),
                ],
                if (team.tracks.length < TrackCatalog.all.length)
                  AppSecondaryButton(
                    buttonText: 'Add another track',
                    leadingIcon: Icons.add_circle_outline,
                    onPressed: () => TrackPickerSheet.show(context),
                  ),
                const SizedBox(height: 12),
                const InviteCard(),
                const SizedBox(height: 12),
                TeamCompositionCard(team: team, ownerTrack: draft.ownerTrack),
              ],

              // Suggested tracks.
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Suggested complementary tracks',
                      style: AppStyles.body11Secondary(context),
                    ),
                    const Spacer(),
                    AppTextButton(
                      buttonText: '⚡ Fast add',
                      onPressed: () {
                        for (final s in suggestions) {
                          notifier.upsertTrack(s.id, people: 1, skills: {});
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in suggestions)
                      AppSkillChip(
                        label: '${s.name} +',
                        onTap: () =>
                            notifier.upsertTrack(s.id, people: 1, skills: {}),
                      ),
                  ],
                ),
              ],

              // Advisor gap warnings.
              for (final w in warnings) ...[
                const SizedBox(height: 10),
                SoftCard(
                  color: c.subtle(c.warning),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: c.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(w, style: AppStyles.body11Primary(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom navigation bar.
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                AppTextButton(
                  buttonText: 'Previous',
                  onPressed: () =>
                      onBack != null ? onBack!() : Navigator.maybePop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPrimaryButton(
                    buttonText: 'Continue to Review',
                    isDisabled: empty,
                    onPressed: () => onNext?.call(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Team Formation')),
            body: body,
          );
  }
}
