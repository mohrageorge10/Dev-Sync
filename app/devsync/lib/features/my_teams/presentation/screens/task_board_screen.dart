import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/task_widgets.dart';

// Kanban task board for managing and filtering team tasks
class TaskBoardScreen extends StatefulWidget {
  final String teamId;
  const TaskBoardScreen({super.key, required this.teamId});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  TaskStatus _status = TaskStatus.inProgress;
  Priority? _priority;
  bool _onlyMine = false;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final team = state.teamById(widget.teamId);
    final all = state.tasksOf(widget.teamId);
    final p = state.progressOf(widget.teamId);
    final pct = p.total == 0 ? 0 : (p.done * 100 / p.total).round();

    final counts = {
      for (final s in TaskStatus.values)
        s: all.where((t) => t.status == s).length
    };

    final visible = all.where((t) {
      if (t.status != _status) return false;
      if (_priority != null && t.priority != _priority) return false;
      if (_onlyMine && t.assignee?.id != state.me.id) return false;
      return true;
    }).toList();

    final unassigned = all
        .where((t) => t.assignee == null && t.status != TaskStatus.done)
        .toList();

    return Scaffold(
      appBar: const AppTopBar('Task Board'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(team.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primary)),
              const SizedBox(height: 2),
              const Text('8 days remaining',
                  style: TextStyle(fontSize: 10.5, color: AppPalette.muted)),
            ]),
            const Spacer(),
            const Icon(Icons.check_circle_outline,
                size: 14, color: AppPalette.primary),
            const SizedBox(width: 4),
            Text('$pct% Completed',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary)),
          ]),
          const SizedBox(height: 14),
          StatusTabs(
              selected: _status,
              counts: counts,
              onChanged: (s) => setState(() => _status = s)),
          const SizedBox(height: 12),
          Row(children: [
            _FilterChip(
              icon: Icons.filter_list,
              label: _priority == null ? 'All Priorities' : _priority!.label,
              onTap: _pickPriority,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              icon: Icons.person_outline,
              label: 'My',
              selected: _onlyMine,
              onTap: () => setState(() => _onlyMine = !_onlyMine),
            ),
            const Spacer(),
            AppPrimaryButton(
              buttonText: 'Create Task',
              leadingIcon: Icons.add,
              isDisabled: false,
              onPressed: () => AppRouter.toCreateTask(context, team),
            ),
          ]),
          const SizedBox(height: 16),
          SectionHeader(
              '${_status.label.toUpperCase()} • ACTIVE DEVELOPMENT',
              trailing: '${visible.length} tasks'),
          if (visible.isEmpty)
            const _EmptyColumn()
          else
            for (final t in visible) ...[
              TaskCard(
                  task: t, onTap: () => AppRouter.toTaskDetails(context, t)),
              const SizedBox(height: 12),
            ],
          if (unassigned.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionHeader('UNASSIGNED TASKS',
                trailing: 'View all ${unassigned.length}'),
            for (final t in unassigned) ...[
              TaskCard(
                  task: t, onTap: () => AppRouter.toTaskDetails(context, t)),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }

  // Shows bottom sheet to select priority filter
  Future<void> _pickPriority() async {
    final res = await showModalBottomSheet<Priority?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              title: const Text('All Priorities'),
              onTap: () => Navigator.pop(ctx, null)),
          for (final p in Priority.values.reversed)
            ListTile(title: Text(p.label), onTap: () => Navigator.pop(ctx, p)),
        ]),
      ),
    );
    setState(() => _priority = res);
  }
}

// Filter chip widget
class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppPalette.softBlue : Colors.white,
          border: Border.all(
              color: selected ? AppPalette.primary : AppPalette.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 14, color: selected ? AppPalette.primary : AppPalette.muted),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppPalette.primary : AppPalette.text)),
        ]),
      ),
    );
  }
}

// Empty state placeholder for task columns
class _EmptyColumn extends StatelessWidget {
  const _EmptyColumn();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: Text('No tasks here yet. Create one to get started.',
              style: TextStyle(fontSize: 12, color: AppPalette.muted)),
        ),
      ),
    );
  }
}
