import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import 'common.dart';

// Badge indicating task priority level
class PriorityPill extends StatelessWidget {
  final Priority priority;
  const PriorityPill(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    switch (priority) {
      case Priority.high:
        return const Pill('High',
            fg: AppPalette.danger,
            bg: AppPalette.dangerBg,
            icon: Icons.arrow_upward);
      case Priority.medium:
        return const Pill('Medium');
      case Priority.low:
        return const Pill('Low', fg: AppPalette.muted, bg: AppPalette.fieldBg);
    }
  }
}

// Card widget displaying task overview and status
class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onTap;
  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PriorityPill(task.priority),
          const SizedBox(width: 8),
          Text('#${task.number} • ${task.tag}',
              style: const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
          const Spacer(),
          const Icon(Icons.more_horiz, size: 18, color: AppPalette.muted),
        ]),
        const SizedBox(height: 10),
        Text(task.title,
            style:
                const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
        if (task.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppPalette.muted)),
        ],
        if (task.subtasksTotal > 0) ...[
          const SizedBox(height: 10),
          InfoStrip(
              icon: Icons.checklist_rounded,
              left:
                  'Subtasks: ${task.subtasksDone}/${task.subtasksTotal} done'),
        ],
        const SizedBox(height: 10),
        Row(children: [
          if (task.assignee != null) ...[
            Avatar(task.assignee!.initials, size: 22),
            const SizedBox(width: 6),
            Text(task.assignee!.name, style: const TextStyle(fontSize: 11.5)),
          ] else ...[
            const Icon(Icons.person_outline, size: 15, color: AppPalette.muted),
            const SizedBox(width: 4),
            const Text('Unassigned',
                style: TextStyle(fontSize: 11.5, color: AppPalette.muted)),
          ],
          const Spacer(),
          if (task.dueDate != null) _DueTag(task.dueDate!),
        ]),
      ]),
    );
  }
}

// Due date badge with urgency indicator
class _DueTag extends StatelessWidget {
  final DateTime date;
  const _DueTag(this.date);

  @override
  Widget build(BuildContext context) {
    final urgent = daysLeft(date) <= 2;
    final label = urgent
        ? 'Due ${fmtDateShort(date)} (${relativeDays(date).toLowerCase()})'
        : 'Due ${fmtDateShort2(date)}';
    final color = urgent ? AppPalette.danger : AppPalette.muted;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.calendar_today_outlined, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}

// Tab bar for switching between task statuses with counts
class StatusTabs extends StatelessWidget {
  final TaskStatus selected;
  final Map<TaskStatus, int> counts;
  final ValueChanged<TaskStatus> onChanged;
  const StatusTabs(
      {super.key,
      required this.selected,
      required this.counts,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.border.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        for (final s in TaskStatus.values)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: s == selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(s.label,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: s == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: s == selected
                                    ? AppPalette.primary
                                    : AppPalette.muted)),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: s == selected
                                ? AppPalette.primary
                                : AppPalette.border,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('${counts[s] ?? 0}',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: s == selected
                                    ? Colors.white
                                    : AppPalette.muted)),
                      ),
                    ]),
              ),
            ),
          ),
      ]),
    );
  }
}
