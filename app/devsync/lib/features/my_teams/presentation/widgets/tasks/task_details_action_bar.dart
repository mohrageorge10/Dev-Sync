import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/widgets/common.dart';
import 'package:devsync/features/my_teams/presentation/widgets/submit_review_dialog.dart';
import 'package:flutter/material.dart';

// Role-aware bottom action bar for task status transitions.
class TaskDetailsActionBar extends StatelessWidget {
  const TaskDetailsActionBar({
    super.key,
    required this.task,
    required this.team,
    required this.canApprove,
    required this.state,
  });

  final TaskItem task;
  final Team team;
  final bool canApprove;
  final TeamsController state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(top: false, child: _buildActions(context, c)),
    );
  }

  Widget _buildActions(BuildContext context, AppColors c) {
    if (task.status == TaskStatus.todo) {
      return AppPrimaryButton(
        buttonText: 'Start Task',
        leadingIcon: Icons.play_arrow_rounded,
        isDisabled: false,
        onPressed: () {
          state.setStatus(task.id, TaskStatus.inProgress);
          showSnack(context, 'Task moved to In Progress');
        },
      );
    }

    if (task.status == TaskStatus.inProgress) {
      final ready = task.allCriteriaDone;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ready) ...[
            Text(
              'Complete all acceptance criteria (${task.subtasksDone}/${task.subtasksTotal}) to submit',
              style: AppStyles.body11Secondary(context),
            ),
            const SizedBox(height: 6),
          ],
          AppPrimaryButton(
            buttonText: 'Submit for Review',
            leadingIcon: Icons.rate_review_outlined,
            isDisabled: !ready,
            onPressed: () async {
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
        ],
      );
    }

    if (task.status == TaskStatus.inReview) {
      if (!canApprove) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: c.subtle(c.warning),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 17, color: c.warning),
              const SizedBox(width: 8),
              Text(
                'Waiting for Owner / Lead review',
                style: AppStyles.body13Bold(context, color: c.warning),
              ),
            ],
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: AppSecondaryButton(
              buttonText: 'Changes',
              leadingIcon: Icons.undo_rounded,
              onPressed: () async {
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
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppPrimaryButton(
              buttonText: 'Approve',
              leadingIcon: Icons.check_rounded,
              isDisabled: false,
              onPressed: () {
                state.setStatus(task.id, TaskStatus.done, reviewNote: '');
                showSnack(
                  context,
                  'Task approved and marked Done',
                  type: AppFeedbackType.success,
                );
              },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: c.subtle(c.success),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, size: 17, color: c.success),
                const SizedBox(width: 6),
                Text(
                  'Completed',
                  style: AppStyles.body13Bold(context, color: c.success),
                ),
              ],
            ),
          ),
        ),
        if (canApprove) ...[
          const SizedBox(width: 10),
          AppSecondaryButton(
            buttonText: 'Reopen',
            onPressed: () {
              state.setStatus(task.id, TaskStatus.inProgress);
              showSnack(context, 'Task reopened to In Progress');
            },
          ),
        ],
      ],
    );
  }
}
