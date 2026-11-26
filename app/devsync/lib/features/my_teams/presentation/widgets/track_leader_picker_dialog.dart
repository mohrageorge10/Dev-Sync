import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Dialog letting the Project Owner pick which project track a leader leads.
Future<String?> showTrackLeaderPickerDialog(
  BuildContext context, {
  required String memberName,
  required List<String> projectTracks,
  String? currentTrack,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _TrackLeaderPickerDialog(
      memberName: memberName,
      projectTracks: projectTracks,
      currentTrack: currentTrack,
    ),
  );
}

class _TrackLeaderPickerDialog extends StatefulWidget {
  const _TrackLeaderPickerDialog({
    required this.memberName,
    required this.projectTracks,
    this.currentTrack,
  });

  final String memberName;
  final List<String> projectTracks;
  final String? currentTrack;

  @override
  State<_TrackLeaderPickerDialog> createState() =>
      _TrackLeaderPickerDialogState();
}

class _TrackLeaderPickerDialogState extends State<_TrackLeaderPickerDialog> {
  String? _selected;
  late final TextEditingController _customCtrl;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentTrack?.trim();
    if (initial != null && initial.isNotEmpty) {
      final match = widget.projectTracks
          .where((t) => t.toLowerCase() == initial.toLowerCase())
          .firstOrNull;
      if (match != null) {
        _selected = match;
        _customCtrl = TextEditingController();
      } else {
        _customCtrl = TextEditingController(text: initial);
      }
    } else {
      _selected = widget.projectTracks.isNotEmpty
          ? widget.projectTracks.first
          : null;
      _customCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  String get _resolvedTrack {
    final custom = _customCtrl.text.trim();
    if (custom.isNotEmpty) return custom;
    return _selected ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final preview = _resolvedTrack.isEmpty
        ? 'Track Leader'
        : '${_resolvedTrack} Leader';

    return AlertDialog(
      backgroundColor: c.backgroundPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Select Track to Lead',
        style: AppStyles.title17Bold(context),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose which track of this project ${widget.memberName} will lead.',
              style: AppStyles.body12Secondary(context),
            ),
            if (widget.projectTracks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Project Tracks',
                style: AppStyles.body11Bold(context, color: c.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final track in widget.projectTracks)
                    ChoiceChip(
                      label: Text(track),
                      selected:
                          _customCtrl.text.trim().isEmpty && _selected == track,
                      selectedColor: c.subtleBlueSurface,
                      backgroundColor: c.surface,
                      side: BorderSide(
                        color:
                            (_customCtrl.text.trim().isEmpty &&
                                _selected == track)
                            ? c.primary
                            : c.border,
                      ),
                      labelStyle: AppStyles.body12SemiBold(
                        context,
                        color:
                            (_customCtrl.text.trim().isEmpty &&
                                _selected == track)
                            ? c.primary
                            : c.textPrimary,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selected = track;
                          _customCtrl.clear();
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _customCtrl,
              onChanged: (_) => setState(() {}),
              style: AppStyles.body13Primary(context),
              decoration: InputDecoration(
                hintText: 'Or type a custom track (e.g. Flutter)',
                hintStyle: AppStyles.body12Secondary(context),
                isDense: true,
                filled: true,
                fillColor: c.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.primary),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Badge: ', style: AppStyles.body11Secondary(context)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.subtle(c.warning),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    preview,
                    style: AppStyles.body11Bold(context, color: c.warning),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: AppStyles.body14Secondary(context)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _resolvedTrack),
          child: Text(
            'Confirm',
            style: AppStyles.body14Bold(context, color: c.primary),
          ),
        ),
      ],
    );
  }
}
