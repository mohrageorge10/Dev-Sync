import 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card for selecting open project tracks and per-track seat counts.
class EditProjectRolesCard extends StatelessWidget {
  const EditProjectRolesCard({
    super.key,
    required this.filledMembers,
    required this.openSeats,
    required this.totalSeats,
    required this.availableTracks,
    required this.selectedTrack,
    required this.trackCounts,
    required this.onAddTrack,
    required this.onChangeCount,
  });

  final int filledMembers;
  final int openSeats;
  final int totalSeats;
  final List<String> availableTracks;
  final String? selectedTrack;
  final Map<String, int> trackCounts;
  final ValueChanged<String?> onAddTrack;
  final void Function(String track, int delta) onChangeCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('Open Roles & Tracks')),
              Text(
                '$totalSeats seats total',
                style: AppStyles.body12Bold(context, color: c.primary),
              ),
            ],
          ),
          Text(
            '$filledMembers filled • $openSeats open',
            style: AppStyles.body11Secondary(context),
          ),
          const SizedBox(height: 12),
          if (availableTracks.isNotEmpty)
            AppDropdownField<String>(
              label: 'Add Track',
              hint: 'Choose a track to add...',
              value: selectedTrack,
              items: availableTracks,
              itemLabel: (t) => t,
              onChanged: onAddTrack,
            ),
          if (trackCounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final entry in trackCounts.entries)
              _TrackSeatRow(
                track: entry.key,
                count: entry.value,
                onDecrement: () => onChangeCount(entry.key, -1),
                onIncrement: () => onChangeCount(entry.key, 1),
              ),
          ],
        ],
      ),
    );
  }
}

// Single track row with inline - count + stepper.
class _TrackSeatRow extends StatelessWidget {
  const _TrackSeatRow({
    required this.track,
    required this.count,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String track;
  final int count;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(Icons.work_outline_rounded, size: 16, color: c.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              track,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.body13Bold(context),
            ),
          ),
          _StepIconButton(
            icon: count == 1 ? Icons.delete_outline : Icons.remove_rounded,
            color: count == 1 ? c.error : c.textPrimary,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppStyles.body14Bold(context),
            ),
          ),
          _StepIconButton(
            icon: Icons.add_rounded,
            color: c.primary,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepIconButton extends StatelessWidget {
  const _StepIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.border),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
