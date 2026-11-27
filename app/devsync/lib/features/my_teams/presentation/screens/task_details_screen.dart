import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/data/services/github_service.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/task_widgets.dart';
import '../widgets/tasks/task_details_action_bar.dart';

// Screen displaying detailed task metadata, PR link, criteria, and actions.
class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final task = state.findTaskById(taskId);
    final team = task == null ? null : state.findTeamById(task.teamId);

    if (task == null || team == null) {
      return Scaffold(
        backgroundColor: c.surface,
        appBar: const AppTopBar('Task Details'),
        body: Center(
          child: Text(
            'This task is no longer available.',
            style: AppStyles.body14Secondary(context),
          ),
        ),
      );
    }

    final canEdit = state.canCreateEditTasks(task.teamId);
    final canApprove = state.canApproveTasks(task.teamId);
    final doneCount = task.criteria.where((item) => item.done).length;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        'Task Details',
        actions: [
          if (canEdit)
            IconButton(
              tooltip: 'Edit task',
              icon: Icon(Icons.edit_outlined, size: 20, color: c.primary),
              onPressed: () => AppRouter.toEditTask(context, task),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, size: 14, color: c.textSecondary),
              const SizedBox(width: 4),
              Text(team.name, style: AppStyles.body11Secondary(context)),
              const Spacer(),
              Pill(team.version, fg: c.textSecondary, bg: c.border),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Pill('# ${task.number} • ${task.epic}', fontSize: 10.5),
              ),
              const SizedBox(width: 8),
              Pill(
                task.status.label,
                fg: _statusColor(c, task.status),
                bg: c.subtle(_statusColor(c, task.status)),
                fontSize: 10.5,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(task.title, style: AppStyles.h2(context)),

          if (task.reviewNote != null && task.reviewNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ReviewNoteBanner(note: task.reviewNote!),
          ],

          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: _MetaBox(
                    label: 'Priority',
                    child: PriorityPill(task.priority),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetaBox(
                    label: 'Due Date',
                    child: Text(
                      task.dueDate == null
                          ? 'Not set'
                          : '${fmtDateShort(task.dueDate!)} (${daysLeft(task.dueDate!)} days)',
                      style: AppStyles.body12SemiBold(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            child: Row(
              children: [
                if (task.assignee != null)
                  Avatar(task.assignee!.initials, size: 34)
                else
                  Icon(Icons.person_outline, color: c.textSecondary),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assignee', style: AppStyles.body11Secondary(context)),
                    Text(
                      task.assignee?.name ?? 'Unassigned',
                      style: AppStyles.body13Bold(context),
                    ),
                    if (task.assignee != null)
                      Text(
                        task.assignee!.role,
                        style: AppStyles.body11Medium(
                          context,
                          color: c.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          if (task.prUrl != null && task.prUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _PrLinkCard(url: task.prUrl!),
          ],

          const SizedBox(height: 16),
          const SectionHeader('Description', trailing: 'Markdown enabled'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description.isEmpty
                      ? 'No description yet.'
                      : task.description,
                  style: AppStyles.body13Primary(context),
                ),
                if (task.codePath != null && task.codePath!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.code, size: 14, color: c.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.codePath!,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontFamily: 'monospace',
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (task.criteria.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionHeader(
              'Acceptance Criteria',
              badge: Pill('$doneCount of ${task.criteria.length}', fontSize: 9.5),
            ),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < task.criteria.length; i++)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: c.primary,
                      value: task.criteria[i].done,
                      onChanged: (_) => state.toggleCriterion(task.id, i),
                      title: Text(
                        task.criteria[i].text,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.criteria[i].done
                              ? c.textSecondary
                              : c.textPrimary,
                          decoration: task.criteria[i].done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (task.comment != null && task.comment!.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Avatar(_initialsFor(task.commentBy), size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${task.commentBy ?? 'Member'} commented',
                          style: AppStyles.body12Bold(context),
                        ),
                        Text(
                          task.comment!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.body11Secondary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: TaskDetailsActionBar(
        task: task,
        team: team,
        canApprove: canApprove,
        state: state,
      ),
    );
  }

  static Color _statusColor(AppColors c, TaskStatus status) => switch (status) {
    TaskStatus.todo => c.textSecondary,
    TaskStatus.inProgress => c.primary,
    TaskStatus.inReview => c.warning,
    TaskStatus.done => c.success,
  };

  static String _initialsFor(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _ReviewNoteBanner extends StatelessWidget {
  const _ReviewNoteBanner({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.subtle(c.warning),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.feedback_outlined, size: 17, color: c.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner Review Note',
                  style: AppStyles.body12Bold(context, color: c.warning),
                ),
                const SizedBox(height: 2),
                Text(note, style: AppStyles.body12Primary(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrLinkCard extends StatefulWidget {
  const _PrLinkCard({required this.url});

  final String url;

  @override
  State<_PrLinkCard> createState() => _PrLinkCardState();
}

class _PrLinkCardState extends State<_PrLinkCard> {
  late Future<GithubPrInfo?> _prFuture;

  @override
  void initState() {
    super.initState();
    _prFuture = GithubService().fetchPullRequestStatus(widget.url);
  }

  @override
  void didUpdateWidget(covariant _PrLinkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _prFuture = GithubService().fetchPullRequestStatus(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FutureBuilder<GithubPrInfo?>(
      future: _prFuture,
      builder: (context, snapshot) {
        final pr = snapshot.data;
        final statusColor = pr == null
            ? c.primary
            : pr.merged
            ? c.primary
            : pr.state.toLowerCase() == 'open'
            ? c.success
            : c.error;

        return AppCard(
          onTap: () => openExternalUrl(context, widget.url),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.subtle(statusColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.merge_type_rounded,
                  color: statusColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pr != null ? 'PR #${pr.number}' : 'Pull Request',
                          style: AppStyles.body11Secondary(context),
                        ),
                        if (pr != null) ...[
                          const SizedBox(width: 6),
                          Pill(
                            pr.displayStatus,
                            fg: statusColor,
                            bg: c.subtle(statusColor),
                            fontSize: 9.5,
                          ),
                          if (pr.additions > 0 || pr.deletions > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '+${pr.additions} / -${pr.deletions}',
                              style: AppStyles.caption10Bold(
                                context,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pr != null ? pr.title : widget.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.body12SemiBold(
                        context,
                        color: c.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 16, color: c.primary),
            ],
          ),
        );
      },
    );
  }
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppStyles.body11Secondary(context)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
