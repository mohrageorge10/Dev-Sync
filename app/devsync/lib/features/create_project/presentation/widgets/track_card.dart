import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/builder_picker_sheet.dart';
import 'package:devsync/features/create_project/presentation/widgets/builder_tile.dart';
import 'package:devsync/features/create_project/presentation/widgets/dashed_add_skill_chip.dart';
import 'package:devsync/features/create_project/presentation/widgets/qty_stepper.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:devsync/features/create_project/presentation/widgets/track_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Track card showing headcount, skills, and queued invites.
class TrackCard extends StatelessWidget {
  const TrackCard({super.key, required this.track});
  final TeamTrack track;

  // Dialog to search or add a custom skill.
  Future<void> _addSkill(BuildContext context) async {
    final cubit = context.read<TeamCubit>();
    final c = TextEditingController();
    final colors = context.colors;

    final skill = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (_, setDialogState) {
          final q = c.text.trim();
          final allKnown = {...track.definition.skills, ...track.skills};
          final suggestions = track.definition.skills
              .where(
                (s) =>
                    !track.skills.contains(s) &&
                    s.toLowerCase().contains(q.toLowerCase()),
              )
              .toList();
          final isNew =
              q.isNotEmpty &&
              q.length <= 24 &&
              !allKnown.any((s) => s.toLowerCase() == q.toLowerCase());

          return AlertDialog(
            backgroundColor: colors.backgroundPrimary,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
            title: Text(
              'Add Skill to ${track.definition.name}',
              style: AppStyles.title16Bold(context),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInputField(
                  controller: c,
                  hint: 'Search or type a skill (e.g. Riverpod)',
                  prefixIcon: Icons.search,
                  onChanged: (_) => setDialogState(() {}),
                  onSubmitted: (v) => Navigator.pop(dialogCtx, v),
                ),
                if (isNew || suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (isNew)
                        DashedAddSkillChip(
                          label: q,
                          onTap: () => Navigator.pop(dialogCtx, q),
                        ),
                      for (final s in suggestions)
                        AppSkillChip(
                          label: s,
                          onTap: () => Navigator.pop(dialogCtx, s),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  'Cancel',
                  style: AppStyles.body12Secondary(context),
                ),
              ),
              if (q.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, q),
                  child: Text(
                    'Add',
                    style: AppStyles.body12Bold(context, color: colors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final s = skill?.trim() ?? '';
    if (s.isNotEmpty && s.length <= 24 && !track.skills.contains(s)) {
      cubit.toggleSkill(track.definition.id, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final id = track.definition.id;
    final notifier = context.read<TeamCubit>();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit and delete actions.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(track.definition.icon, size: 16, color: c.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  track.definition.name,
                  style: AppStyles.body13Bold(context),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: c.textSecondary,
                ),
                onPressed: () =>
                    TrackPickerSheet.show(context, editTrackId: id),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.delete_outline, size: 18, color: c.error),
                onPressed: () {
                  notifier.removeTrack(id);
                  AppFeedback.show(
                    context,
                    title: 'Track Removed',
                    message: '${track.definition.name} was removed from team.',
                    type: AppFeedbackType.warning,
                    actionLabel: 'Undo',
                    onAction: notifier.undoRemove,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Headcount stepper.
          Row(
            children: [
              Text('People needed', style: AppStyles.body12Secondary(context)),
              const Spacer(),
              QtyStepper(
                value: track.people,
                max: 6,
                onChanged: (n) {
                  final err = notifier.setPeople(id, n);
                  if (err != null) {
                    AppFeedback.show(
                      context,
                      title: 'Headcount Limit',
                      message: err,
                      type: AppFeedbackType.warning,
                      fromTop: true,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Skills chips.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in track.skills)
                AppSkillChip(
                  label: s,
                  selected: true,
                  onTap: () => notifier.toggleSkill(id, s),
                ),
              AppSkillChip(
                label: '+ Add skills',
                onTap: () => _addSkill(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Skills optional', style: AppStyles.caption10Secondary(context)),

          // Pending invitations list.
          for (final inv in track.invites) ...[
            const Divider(height: 22),
            Text(
              'ASSIGNED TEAMMATE',
              style: AppStyles.overline9Secondary(context, letterSpacing: .5),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                BuilderAvatar(builder: inv.builder, radius: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.builder.name,
                        style: AppStyles.body12Bold(context),
                      ),
                      Text(
                        inv.builder.displayHandle,
                        style: AppStyles.caption10Secondary(context),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppBadge.warning(context, 'Pending'),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => notifier.cancelInvite(id, inv.builder.id),
                      child: Text(
                        'Cancel invite',
                        style: AppStyles.caption10Secondary(
                          context,
                          color: c.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],

          // Invite button for remaining open spots.
          if (track.openSpots > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: AppTextButton(
                  leadingIcon: Icons.person_add_alt,
                  buttonText:
                      'Invite ${track.definition.name} (${track.openSpots} open)',
                  onPressed: () =>
                      BuilderPickerSheet.show(context, lockedTrackId: id),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
