import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/scored_builder.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';
import 'package:devsync/features/create_project/presentation/cubit/builder_search/builder_search_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/builder_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bottom sheet to search and invite developers.
class BuilderPickerSheet extends StatefulWidget {
  const BuilderPickerSheet({
    super.key,
    this.initialQuery = '',
    this.lockedTrackId,
  });

  final String initialQuery;
  final String? lockedTrackId;

  // Open picker sheet with scoped search cubit.
  static Future<void> show(
    BuildContext context, {
    String initialQuery = '',
    String? lockedTrackId,
  }) {
    final teamCubit = context.read<TeamCubit>();
    final repo = ServiceLocator.isRegistered<BuildersRepository>()
        ? ServiceLocator.get<BuildersRepository>()
        : context.read<BuildersRepository>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: teamCubit),
          BlocProvider(
            create: (_) => BuilderSearchCubit(
              repository: repo,
              teamCubit: teamCubit,
            )..start(initialQuery, trackId: lockedTrackId),
          ),
        ],
        child: BuilderPickerSheet(
          initialQuery: initialQuery,
          lockedTrackId: lockedTrackId,
        ),
      ),
    );
  }

  @override
  State<BuilderPickerSheet> createState() => _BuilderPickerSheetState();
}

class _BuilderPickerSheetState extends State<BuilderPickerSheet> {
  late final _search = TextEditingController(text: widget.initialQuery);
  final _message = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    _message.dispose();
    super.dispose();
  }

  // Send invitations to all selected developers.
  void _sendAll(List<ScoredBuilder> selected, String? trackId) {
    if (selected.isEmpty || trackId == null) return;
    final teamCubit = context.read<TeamCubit>();
    var count = 0;
    String? lastErr;

    for (final s in selected) {
      final err = teamCubit.invite(s.builder, trackId, message: _message.text);
      err == null ? count++ : lastErr = err;
    }

    if (count == 0 && lastErr != null) {
      AppFeedback.show(
        context,
        title: 'Cannot Invite',
        message: lastErr,
        type: AppFeedbackType.error,
        fromTop: true,
      );
      return;
    }

    final names = selected.map((s) => s.builder.name).join(', ');
    Navigator.pop(context);
    AppFeedback.show(
      context,
      title: count == 1 ? 'Invitation Queued' : '$count Invitations Queued',
      message: 'Invited $names',
      type: AppFeedbackType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final search = context.watch<BuilderSearchCubit>().state;
    final team = context.watch<TeamCubit>().state;
    final notifier = context.read<BuilderSearchCubit>();

    final openTracks = team.tracks
        .where((t) =>
            t.openSpots > 0 &&
            (widget.lockedTrackId == null ||
                t.definition.id == widget.lockedTrackId))
        .toList();

    final activeId = widget.lockedTrackId ?? search.joinTrackId;
    final activeTrack =
        openTracks.where((t) => t.definition.id == activeId).firstOrNull;
    final visible = search.visibleResults;
    final selected = search.selectedBuilders;
    final maxSpots = activeTrack?.openSpots ?? 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle and header.
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  activeTrack != null && widget.lockedTrackId != null
                      ? 'Invite ${activeTrack.definition.name} Developers'
                      : 'Invite Registered Developers',
                  style: AppStyles.title16Bold(context),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),

          // Track slot chips.
          if (openTracks.isNotEmpty) ...[
            Text(
              widget.lockedTrackId != null
                  ? 'Target Track Slot'
                  : 'Select Track Slot',
              style: AppStyles.body11SemiBold(context, color: c.textSecondary),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  if (widget.lockedTrackId == null && openTracks.length > 1)
                    _TrackSlotChip(
                      icon: Icons.apps_rounded,
                      label: 'All Open Tracks',
                      spotsLabel:
                          '${openTracks.fold<int>(0, (s, t) => s + t.openSpots)} spots',
                      selected: activeId == null,
                      onTap: () => notifier.setJoinTrack(null),
                    ),
                  for (final t in openTracks)
                    _TrackSlotChip(
                      icon: t.definition.icon,
                      label: t.definition.name,
                      spotsLabel:
                          '${t.openSpots} spot${t.openSpots > 1 ? 's' : ''}',
                      selected: activeId == t.definition.id,
                      onTap: widget.lockedTrackId != null
                          ? null
                          : () => notifier.setJoinTrack(
                                activeId == t.definition.id
                                    ? null
                                    : t.definition.id,
                              ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Search input field.
          AppInputField(
            controller: _search,
            hint: 'Search name, @publicId, or skill',
            prefixIcon: Icons.search,
            onChanged: notifier.onQueryChanged,
          ),
          const SizedBox(height: 12),

          // Results count and selection counter.
          Row(
            children: [
              Text(
                activeTrack != null
                    ? '${activeTrack.definition.name.toUpperCase()} DEVELOPERS (${visible.length})'
                    : 'MATCHING DEVELOPERS (${visible.length})',
                style: AppStyles.caption10Bold(
                  context,
                  color: c.textSecondary,
                  letterSpacing: .5,
                ),
              ),
              const Spacer(),
              AppBadge.info(
                context,
                activeTrack != null
                    ? '${selected.length} / $maxSpots Selected'
                    : '${selected.length} Selected',
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Developers list.
          Flexible(
            child: search.loading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            openTracks.isEmpty
                                ? 'No open track slots left.'
                                : 'No available developers match your filter.',
                            textAlign: TextAlign.center,
                            style: AppStyles.body12Secondary(context),
                          ),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          for (final r in visible)
                            BuilderTile(
                              builder: r.builder,
                              percent: r.percent,
                              selected: search.selectedIds.contains(r.builder.id),
                              onTap: () {
                                final err = notifier.toggleSelect(r);
                                if (err != null) {
                                  AppFeedback.show(
                                    context,
                                    title: 'Slot Limit Reached',
                                    message: err,
                                    type: AppFeedbackType.warning,
                                    fromTop: true,
                                  );
                                }
                              },
                            ),
                        ],
                      ),
          ),
          const SizedBox(height: 10),

          // Optional message and submit button.
          AppInputField(
            controller: _message,
            label: 'Invitation Message',
            trailingLabel: 'Optional',
            hint: 'e.g. Would love to have you join our team!',
            enabled: selected.isNotEmpty,
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            buttonText: selected.length <= 1
                ? 'Send Invitation'
                : 'Send ${selected.length} Invitations',
            leadingIcon: Icons.send_outlined,
            isDisabled: selected.isEmpty || activeId == null,
            onPressed: () => _sendAll(selected, activeId),
          ),
        ],
      ),
    );
  }
}

// Selectable track slot pill.
class _TrackSlotChip extends StatelessWidget {
  const _TrackSlotChip({
    required this.icon,
    required this.label,
    required this.spotsLabel,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label, spotsLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.subtleBlueSurface : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? c.primary : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? c.primary : c.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppStyles.body12Bold(
                context,
                color: selected ? c.primary : c.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? c.primary : c.backgroundPrimary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                spotsLabel,
                style: AppStyles.caption10Bold(
                  context,
                  color: selected ? c.onPrimary : c.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
