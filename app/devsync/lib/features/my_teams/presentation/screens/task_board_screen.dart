import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/task_widgets.dart';
import '../widgets/tasks/task_board_actions.dart';

// Role-aware Kanban task board for managing and filtering team tasks.
class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key, required this.teamId});

  final String teamId;

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  TaskStatus _status = TaskStatus.inProgress;
  Priority? _priority;
  bool _onlyMine = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(widget.teamId);
    if (team == null) {
      return const Scaffold(
        appBar: AppTopBar('Task Board'),
        body: Center(child: Text('Team not found')),
      );
    }

    final isOwner = state.isOwnerOf(widget.teamId);
    final canCreate = state.canCreateEditTasks(widget.teamId);
    final canViewAll = state.canViewAllTasks(widget.teamId);
    final scopedTasks = state.visibleTasksOf(widget.teamId);
    final p = state.progressOf(widget.teamId);
    final pct = p.total == 0 ? 0 : (p.done * 100 / p.total).round();

    final counts = {
      for (final s in TaskStatus.values)
        s: scopedTasks.where((t) => t.status == s).length,
    };

    // Show unassigned tasks only in To Do and only for the Owner.
    final unassigned = isOwner && _status == TaskStatus.todo && !_onlyMine
        ? scopedTasks.where((t) {
            if (t.status != TaskStatus.todo || t.assignee != null) return false;
            if (_priority != null && t.priority != _priority) return false;
            return true;
          }).toList()
        : const <TaskItem>[];

    final visible = scopedTasks.where((t) {
      if (t.status != _status) return false;
      if (_priority != null && t.priority != _priority) return false;
      if (canViewAll && _onlyMine && t.assignee?.id != state.me.id) return false;
      if (isOwner &&
          _status == TaskStatus.todo &&
          !_onlyMine &&
          t.assignee == null) {
        return false;
      }
      return true;
    }).toList();

    final daysLeftText = team.daysRemaining == null
        ? team.sprint
        : '${team.daysRemaining} days remaining';

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar('Task Board'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name.toUpperCase(),
                    style: AppStyles.body11Bold(context, color: c.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(daysLeftText, style: AppStyles.body11Secondary(context)),
                ],
              ),
              const Spacer(),
              Icon(Icons.check_circle_outline, size: 14, color: c.primary),
              const SizedBox(width: 4),
              Text(
                '$pct% Completed',
                style: AppStyles.body11Bold(context, color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatusTabs(
            selected: _status,
            counts: counts,
            onChanged: (s) => setState(() => _status = s),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TaskFilterChip(
                icon: Icons.filter_list,
                label: _priority == null ? 'All Priorities' : _priority!.label,
                onTap: _pickPriority,
              ),
              if (canViewAll) ...[
                const SizedBox(width: 8),
                TaskFilterChip(
                  icon: Icons.person_outline,
                  label: 'My',
                  selected: _onlyMine,
                  onTap: () => setState(() => _onlyMine = !_onlyMine),
                ),
              ],
              if (canCreate) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: AppPrimaryButton(
                    buttonText: 'Create Task',
                    leadingIcon: Icons.add,
                    isDisabled: false,
                    onPressed: () => AppRouter.toCreateTask(context, team),
                  ),
                ),
              ] else if (!canViewAll) ...[
                const Spacer(),
                Pill(
                  'My Tasks Only',
                  fg: c.textSecondary,
                  bg: c.backgroundPrimary,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SectionHeader(
            '${_status.label.toUpperCase()} • ${canViewAll ? 'TEAM BOARD' : 'MY TASKS'}',
            trailing: '${visible.length} tasks',
          ),
          if (visible.isEmpty && unassigned.isEmpty)
            _EmptyColumn(canCreate: canCreate)
          else
            for (final t in visible) ...[
              TaskCard(
                task: t,
                onTap: () => AppRouter.toTaskDetails(context, t),
                onMoreTap: () => showTaskQuickActionsSheet(
                  context,
                  state: state,
                  team: team,
                  task: t,
                ),
              ),
              const SizedBox(height: 12),
            ],
          if (unassigned.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionHeader(
              'UNASSIGNED TASKS',
              trailing: '${unassigned.length} unassigned',
            ),
            for (final t in unassigned) ...[
              TaskCard(
                task: t,
                onTap: () => AppRouter.toTaskDetails(context, t),
                onMoreTap: () => showTaskQuickActionsSheet(
                  context,
                  state: state,
                  team: team,
                  task: t,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _pickPriority() async {
    final c = context.colors;
    final res = await showModalBottomSheet<Priority?>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'All Priorities',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () => Navigator.pop(ctx, null),
            ),
            for (final p in Priority.values.reversed)
              ListTile(
                title: Text(p.label, style: AppStyles.body14Primary(ctx)),
                onTap: () => Navigator.pop(ctx, p),
              ),
          ],
        ),
      ),
    );
    if (mounted) setState(() => _priority = res);
  }
}

class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text(
            canCreate
                ? 'No tasks in this column yet. Create one to get started.'
                : 'No tasks assigned to you in this column.',
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
        ),
      ),
    );
  }
}
