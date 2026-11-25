import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/widgets/common.dart';
import 'package:devsync/features/my_teams/presentation/widgets/submit_review_dialog.dart';
import 'package:flutter/material.dart';

// Role-aware quick actions bottom sheet for a task card.
Future<void> showTaskQuickActionsSheet(
  BuildContext context, {
  required TeamsController state,
  required Team team,
  required TaskItem task,
}) async {
  final c = context.colors;
  final canEdit = state.canCreateEditTasks(team.id);
  final canDelete = state.canDeleteTasks(team.id);
  final canApprove = state.canApproveTasks(team.id);

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: c.backgroundPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          if (task.status == TaskStatus.todo)
            ListTile(
              leading: Icon(Icons.play_arrow_rounded, color: c.primary),
              title: Text(
                'Move to In Progress',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () {
                Navigator.pop(ctx);
                state.setStatus(task.id, TaskStatus.inProgress);
                showSnack(context, 'Task moved to In Progress');
              },
            ),
          if (task.status == TaskStatus.inProgress)
            ListTile(
              enabled: task.allCriteriaDone,
              leading: Icon(
                Icons.rate_review_outlined,
                color: task.allCriteriaDone ? c.warning : c.textSecondary,
              ),
              title: Text(
                'Submit for Review',
                style: task.allCriteriaDone
                    ? AppStyles.body14Primary(ctx)
                    : AppStyles.body14Secondary(ctx),
              ),
              subtitle: task.allCriteriaDone
                  ? null
                  : Text(
                      'Complete all acceptance criteria (${task.subtasksDone}/${task.subtasksTotal}) first',
                      style: AppStyles.body11Secondary(ctx),
                    ),
              onTap: () async {
                Navigator.pop(ctx);
                String? prUrl;
                if (team.settings.requirePrCheck) {
                  final res = await showSubmitForReviewDialog(
                    context,
                    existingPrUrl: task.prUrl,
                  );
                  if (res == null || !res.confirmed || !context.mounted) return;
                  prUrl = res.prUrl;
                }
                await state.setStatus(
                  task.id,
                  TaskStatus.inReview,
                  prUrl: prUrl,
                );
                if (context.mounted) {
                  showSnack(
                    context,
                    'Task moved to In Review',
                    type: AppFeedbackType.success,
                  );
                }
              },
            ),
          if (canApprove && task.status == TaskStatus.inReview) ...[
            ListTile(
              leading: Icon(Icons.check_circle_outline, color: c.success),
              title: Text(
                'Approve & Mark Done',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () {
                Navigator.pop(ctx);
                state.setStatus(task.id, TaskStatus.done, reviewNote: '');
                showSnack(
                  context,
                  'Task approved and marked Done',
                  type: AppFeedbackType.success,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.undo_rounded, color: c.warning),
              title: Text(
                'Request Changes',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final note = await showRequestChangesDialog(context);
                if (note == null || !context.mounted) return;
                await state.setStatus(
                  task.id,
                  TaskStatus.inProgress,
                  reviewNote: note,
                );
                if (context.mounted) {
                  showSnack(context, 'Sent back to In Progress');
                }
              },
            ),
          ],
          if (canEdit)
            ListTile(
              leading: Icon(Icons.edit_outlined, color: c.textPrimary),
              title: Text(
                'Edit / Assign Task',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () {
                Navigator.pop(ctx);
                AppRouter.toEditTask(context, task);
              },
            ),
          if (canDelete)
            ListTile(
              leading: Icon(Icons.delete_outline, color: c.error),
              title: Text(
                'Delete Task',
                style: AppStyles.body14Bold(ctx, color: c.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                state.deleteTask(task.teamId, task.id);
                showSnack(context, 'Task deleted');
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

// Compact filter chip used on the task board toolbar.
class TaskFilterChip extends StatelessWidget {
  const TaskFilterChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.subtleBlueSurface : c.backgroundPrimary,
          border: Border.all(color: selected ? c.primary : c.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? c.primary : c.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppStyles.body11Bold(
                context,
                color: selected ? c.primary : c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
