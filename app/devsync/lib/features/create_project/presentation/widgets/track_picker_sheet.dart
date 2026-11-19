import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/dashed_add_skill_chip.dart';
import 'package:devsync/features/create_project/presentation/widgets/qty_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bottom sheet to add or edit a team track.
class TrackPickerSheet extends StatefulWidget {
  const TrackPickerSheet({super.key, this.editTrackId});
  final String? editTrackId;

  static Future<void> show(BuildContext context, {String? editTrackId}) {
    final teamCubit = context.read<TeamCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: teamCubit,
        child: TrackPickerSheet(editTrackId: editTrackId),
      ),
    );
  }

  @override
  State<TrackPickerSheet> createState() => _TrackPickerSheetState();
}

class _TrackPickerSheetState extends State<TrackPickerSheet> {
  String? _selectedId;
  int _people = 1;
  final _skills = <String>{};
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final id = widget.editTrackId;
    if (id != null) {
      final t = context.read<TeamCubit>().state.byId(id);
      if (t != null) {
        _selectedId = id;
        _people = t.people;
        _skills.addAll(t.skills);
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _select(String id) => setState(() {
        if (_selectedId != id) _skills.clear();
        _selectedId = id;
      });

  void _addCustom(String v) {
    final s = v.trim();
    if (s.isEmpty || s.length > 24) return;
    setState(() {
      _skills.add(s);
      _search.clear();
      _query = '';
    });
  }

  void _save() {
    final err = context
        .read<TeamCubit>()
        .upsertTrack(_selectedId!, people: _people, skills: _skills);
    if (err != null) {
      AppFeedback.show(
        context,
        title: 'Cannot Save Track',
        message: err,
        type: AppFeedbackType.warning,
        fromTop: true,
      );
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final team = context.watch<TeamCubit>().state;
    final selected =
        _selectedId == null ? null : TrackCatalog.byId(_selectedId!);

    final pool = <String>{...?selected?.skills, ..._skills};
    final q = _query.trim();
    final matching =
        pool.where((s) => s.toLowerCase().contains(q.toLowerCase())).toList();
    final canAddCustom = selected != null &&
        q.isNotEmpty &&
        q.length <= 24 &&
        !pool.any((s) => s.toLowerCase() == q.toLowerCase());

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
      child: SingleChildScrollView(
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
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.editTrackId == null
                      ? 'Add Team Track'
                      : 'Edit Team Track',
                  style: AppStyles.title16Bold(context),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            Row(
              children: [
                Text('Select Track', style: AppStyles.body12Secondary(context)),
                const Spacer(),
                Text(
                  '${team.tracks.length} already active',
                  style: AppStyles.caption10Secondary(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tracks grid.
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final t in TrackCatalog.all)
                  _TrackTile(
                    def: t,
                    selected: _selectedId == t.id,
                    locked: team.hasTrack(t.id) && t.id != widget.editTrackId,
                    onTap: () => _select(t.id),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Headcount stepper.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.secondarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('People needed', style: AppStyles.body12Bold(context)),
                        Text(
                          'Headcount for this track',
                          style: AppStyles.caption10Secondary(context),
                        ),
                      ],
                    ),
                  ),
                  QtyStepper(
                    value: _people,
                    max: 6,
                    onChanged: (n) => setState(() => _people = n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Skills search and selection chips.
            Text('Skills (optional)', style: AppStyles.body12Bold(context)),
            Text(
              "Skills are optional. Add any specific tools you'd like.",
              style: AppStyles.caption10Secondary(context),
            ),
            const SizedBox(height: 8),
            AppInputField(
              controller: _search,
              enabled: selected != null,
              hint: 'Search or type a custom skill (e.g. PyTorch)',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: _addCustom,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (canAddCustom)
                  DashedAddSkillChip(label: q, onTap: () => _addCustom(q)),
                for (final s in matching)
                  AppSkillChip(
                    label: s,
                    selected: _skills.contains(s),
                    onTap: () => setState(() => _skills.contains(s)
                        ? _skills.remove(s)
                        : _skills.add(s)),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Save button.
            AppPrimaryButton(
              buttonText: 'Save Track',
              trailingIcon: Icons.arrow_forward,
              isDisabled: _selectedId == null,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// Track grid tile.
class _TrackTile extends StatelessWidget {
  const _TrackTile({
    required this.def,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final TrackDefinition def;
  final bool selected, locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: locked
          ? () => AppFeedback.show(
                context,
                title: 'Track Already Added',
                message:
                    '${def.name} is already in your project. Use the edit icon on its card.',
                type: AppFeedbackType.info,
                fromTop: true,
              )
          : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? c.subtleBlueSurface
              : (locked ? c.secondarySurface : c.backgroundPrimary),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? c.primary : c.border),
        ),
        child: Row(
          children: [
            Icon(
              def.icon,
              size: 18,
              color: locked ? c.textSecondary : c.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.body12Bold(
                      context,
                      color: locked ? c.textSecondary : c.textPrimary,
                    ),
                  ),
                  Text(
                    selected
                        ? 'Selected'
                        : (locked ? 'In project' : 'Available'),
                    style: AppStyles.overline9Secondary(context),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle
                  : (locked ? Icons.lock_outline : Icons.add),
              size: 16,
              color: selected ? c.primary : c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
