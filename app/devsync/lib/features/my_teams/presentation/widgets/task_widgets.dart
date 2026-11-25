import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import 'common.dart';

// Badge indicating task priority level.
class PriorityPill extends StatelessWidget {
  const PriorityPill(this.priority, {super.key});

  final Priority priority;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    switch (priority) {
      case Priority.high:
        return Pill(
          'High',
          fg: c.error,
          bg: c.subtle(c.error),
          icon: Icons.arrow_upward,
        );
      case Priority.medium:
        return const Pill('Medium');
      case Priority.low:
        return Pill('Low', fg: c.textSecondary, bg: c.surface);
    }
  }
}

// Card widget displaying task overview, PR/review indicators, and quick actions.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onMoreTap,
  });

  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasPr = task.prUrl != null && task.prUrl!.trim().isNotEmpty;
    final hasReviewNote =
        task.reviewNote != null && task.reviewNote!.trim().isNotEmpty;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PriorityPill(task.priority),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '#${task.number} • ${task.tag}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.body11Secondary(context),
                ),
              ),
              if (hasPr) ...[
                Icon(Icons.merge_type_rounded, size: 16, color: c.primary),
                const SizedBox(width: 4),
              ],
              if (hasReviewNote) ...[
                Icon(Icons.feedback_outlined, size: 15, color: c.warning),
                const SizedBox(width: 4),
              ],
              if (onMoreTap != null)
                InkWell(
                  onTap: onMoreTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(task.title, style: AppStyles.title15Bold(context)),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.body12Secondary(context),
            ),
          ],
          if (task.subtasksTotal > 0) ...[
            const SizedBox(height: 10),
            InfoStrip(
              icon: Icons.checklist_rounded,
              left: 'Subtasks: ${task.subtasksDone}/${task.subtasksTotal} done',
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              if (task.assignee != null) ...[
                Avatar(task.assignee!.initials, size: 22),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    task.assignee!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.body12Primary(context),
                  ),
                ),
              ] else ...[
                Icon(Icons.person_outline, size: 15, color: c.textSecondary),
                const SizedBox(width: 4),
                Text('Unassigned', style: AppStyles.body12Secondary(context)),
              ],
              const Spacer(),
              if (task.dueDate != null) _DueTag(task.dueDate!),
            ],
          ),
        ],
      ),
    );
  }
}

// Due date badge with urgency indicator.
class _DueTag extends StatelessWidget {
  const _DueTag(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final urgent = daysLeft(date) <= 2;
    final label = urgent
        ? 'Due ${fmtDateShort(date)} (${relativeDays(date).toLowerCase()})'
        : 'Due ${fmtDateShort2(date)}';
    final color = urgent ? c.error : c.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppStyles.body11Bold(context, color: color)),
      ],
    );
  }
}

// Tab bar for switching between task statuses with counts.
class StatusTabs extends StatelessWidget {
  const StatusTabs({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final TaskStatus selected;
  final Map<TaskStatus, int> counts;
  final ValueChanged<TaskStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          for (final s in TaskStatus.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: s == selected
                        ? c.backgroundPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          s.label,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: s == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: s == selected ? c.primary : c.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: s == selected ? c.primary : c.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${counts[s] ?? 0}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: s == selected ? c.onPrimary : c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
