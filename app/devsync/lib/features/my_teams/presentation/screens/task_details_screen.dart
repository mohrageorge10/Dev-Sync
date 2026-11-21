import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/task_widgets.dart';

// Screen displaying detailed task metadata, criteria, and actions
class TaskDetailsScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final task = state.taskById(taskId);
    final team = state.teamById(task.teamId);
    final doneCount = task.criteria.where((c) => c.done).length;

    return Scaffold(
      appBar: const AppTopBar('Task Details'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            const Icon(Icons.folder_outlined, size: 14, color: AppPalette.muted),
            const SizedBox(width: 4),
            Text(team.name,
                style: const TextStyle(fontSize: 11, color: AppPalette.muted)),
            const Spacer(),
            Pill(team.version, fg: AppPalette.muted, bg: AppPalette.border),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Pill('# ${task.number} • ${task.epic}', fontSize: 9.5),
            const Spacer(),
            Pill(task.status.label.toLowerCase(),
                fg: AppPalette.muted, bg: AppPalette.fieldBg, fontSize: 9.5),
          ]),
          const SizedBox(height: 10),
          Text(task.title,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w800, height: 1.25)),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              Expanded(
                child: _MetaBox(
                    label: 'Priority',
                    child: PriorityPill(task.priority)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetaBox(
                  label: 'Due Date',
                  child: Text(
                      task.dueDate == null
                          ? 'Not set'
                          : '${fmtDateShort(task.dueDate!)} (${daysLeft(task.dueDate!)} days)',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Row(children: [
              if (task.assignee != null)
                Avatar(task.assignee!.initials, size: 34)
              else
                const Icon(Icons.person_outline, color: AppPalette.muted),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Assignee',
                    style: TextStyle(fontSize: 10, color: AppPalette.muted)),
                Text(task.assignee?.name ?? 'Unassigned',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                if (task.assignee != null)
                  Text(task.assignee!.role,
                      style: const TextStyle(
                          fontSize: 10, color: AppPalette.primary)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const SectionHeader('Description', trailing: 'Markdown enabled'),
          AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  task.description.isEmpty
                      ? 'No description yet.'
                      : task.description,
                  style: const TextStyle(fontSize: 12, height: 1.45)),
              if (task.codePath != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppPalette.fieldBg,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.code, size: 14, color: AppPalette.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(task.codePath!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10.5, fontFamily: 'monospace')),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          if (task.criteria.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeader('Acceptance Criteria',
                badge: Pill('$doneCount of ${task.criteria.length}',
                    fontSize: 9.5)),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(children: [
                for (var i = 0; i < task.criteria.length; i++)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppPalette.primary,
                    value: task.criteria[i].done,
                    onChanged: (_) => state.toggleCriterion(task.id, i),
                    title: Text(task.criteria[i].text,
                        style: TextStyle(
                            fontSize: 12,
                            color: task.criteria[i].done
                                ? AppPalette.muted
                                : AppPalette.text,
                            decoration: task.criteria[i].done
                                ? TextDecoration.lineThrough
                                : null)),
                  ),
              ]),
            ),
          ],
          if (task.comment != null) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Row(children: [
                const Avatar('SC', size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${task.commentBy} commented',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(task.comment!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10.5, color: AppPalette.muted)),
                      ]),
                ),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppPalette.muted),
              ]),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppPalette.border))),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: SafeArea(
          top: false,
          child: Row(children: [
            Expanded(
              child: AppSecondaryButton(
                buttonText: task.status == TaskStatus.inReview
                    ? 'In Review'
                    : 'Mark In Review',
                leadingIcon: Icons.rate_review_outlined,
                onPressed: () {
                  state.setStatus(task.id, TaskStatus.inReview);
                  showSnack(context, 'Task moved to In Review');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppPrimaryButton(
                buttonText: 'Edit Task',
                leadingIcon: Icons.edit_outlined,
                isDisabled: false,
                onPressed: () => AppRouter.toEditTask(context, task),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// Metadata container box for task attributes
class _MetaBox extends StatelessWidget {
  final String label;
  final Widget child;
  const _MetaBox({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppPalette.fieldBg, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppPalette.muted)),
        const SizedBox(height: 6),
        child,
      ]),
    );
  }
}
