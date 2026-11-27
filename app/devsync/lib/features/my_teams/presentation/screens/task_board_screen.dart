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
  static const _unassignedKey = '__unassigned__';

  TaskStatus _status = TaskStatus.inProgress;
  Priority? _priority;
  bool _onlyMine = false;
  String? _selectedMemberId;

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

    final hasMemberFilter = isOwner && _selectedMemberId != null;

    // Filter tasks by priority and selected member (for Owner) or My toggle.
    bool matchesFilters(TaskItem t) {
      if (_priority != null && t.priority != _priority) return false;
      if (isOwner) {
        if (_selectedMemberId == _unassignedKey) {
          return t.assignee == null;
        }
        if (_selectedMemberId != null) {
          return t.assignee?.id == _selectedMemberId;
        }
      } else if (canViewAll && _onlyMine) {
        return t.assignee?.id == state.me.id;
      }
      return true;
    }

    final filteredAcrossStatuses = scopedTasks.where(matchesFilters).toList();
    final counts = {
      for (final s in TaskStatus.values)
        s: filteredAcrossStatuses.where((t) => t.status == s).length,
    };

    // Show separate Unassigned section in To Do for Owner when no member filter is active.
    final unassigned = isOwner && _status == TaskStatus.todo && !hasMemberFilter
        ? filteredAcrossStatuses
            .where((t) => t.status == TaskStatus.todo && t.assignee == null)
            .toList()
        : const <TaskItem>[];

    final visible = filteredAcrossStatuses.where((t) {
      if (t.status != _status) return false;
      if (isOwner &&
          _status == TaskStatus.todo &&
          !hasMemberFilter &&
          t.assignee == null) {
        return false;
      }
      return true;
    }).toList();

    final selectedMember = _selectedMemberId == null ||
            _selectedMemberId == _unassignedKey
        ? null
        : team.members.where((m) => m.id == _selectedMemberId).firstOrNull;
    final memberFilterLabel = _selectedMemberId == _unassignedKey
        ? 'Unassigned'
        : selectedMember != null
        ? (selectedMember.id == state.me.id
            ? 'My'
            : selectedMember.name.split(' ').first)
        : 'Members';

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
                selected: _priority != null,
                onTap: _pickPriority,
              ),
              if (isOwner) ...[
                const SizedBox(width: 8),
                TaskFilterChip(
                  icon: Icons.people_outline,
                  label: memberFilterLabel,
                  selected: hasMemberFilter,
                  onTap: () => _pickMember(team, state.me.id),
                ),
              ] else if (canViewAll) ...[
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

  // Bottom sheet allowing the Owner to filter tasks by a specific team member or unassigned.
  Future<void> _pickMember(Team team, String myId) async {
    final c = context.colors;
    const clearSentinel = '__all__';
    final res = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filter by Member',
                    style: AppStyles.title15Bold(ctx),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.groups_outlined, color: c.primary),
                title: Text('All Members', style: AppStyles.body14Primary(ctx)),
                trailing: _selectedMemberId == null
                    ? Icon(Icons.check, color: c.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, clearSentinel),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_off_outlined,
                  color: c.textSecondary,
                ),
                title: Text('Unassigned', style: AppStyles.body14Primary(ctx)),
                trailing: _selectedMemberId == _unassignedKey
                    ? Icon(Icons.check, color: c.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, _unassignedKey),
              ),
              const Divider(height: 1),
              for (final m in team.members)
                ListTile(
                  leading: Avatar(m.initials, size: 32),
                  title: Text(
                    m.id == myId ? '${m.name} (You)' : m.name,
                    style: AppStyles.body14Primary(ctx),
                  ),
                  subtitle: Text(
                    m.role,
                    style: AppStyles.body12Secondary(ctx),
                  ),
                  trailing: _selectedMemberId == m.id
                      ? Icon(Icons.check, color: c.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, m.id),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!mounted || res == null) return;
    setState(() {
      _selectedMemberId = res == clearSentinel ? null : res;
    });
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
