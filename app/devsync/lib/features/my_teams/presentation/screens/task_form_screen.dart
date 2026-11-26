import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';
import '../widgets/tasks/task_form_fields.dart';

// Permission-gated screen for creating, editing, assigning, and deleting tasks.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.teamId, this.taskId});

  final String teamId;
  final String? taskId;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _tag;
  late final TextEditingController _criterionInput;
  final List<Criterion> _criteria = [];
  Priority _priority = Priority.medium;
  Member? _assignee;
  DateTime? _due;
  bool _loaded = false;
  static const _maxDesc = 500;

  bool get _isEdit => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _desc = TextEditingController();
    _tag = TextEditingController(text: 'General');
    _criterionInput = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (_isEdit) {
      final t = TeamsScope.of(context).findTaskById(widget.taskId!);
      if (t != null) {
        _title.text = t.title;
        _desc.text = t.description;
        _tag.text = t.tag;
        _priority = t.priority;
        _assignee = t.assignee;
        _due = t.dueDate;
        _criteria.addAll(
          t.criteria.map((c) => Criterion(c.text, done: c.done)),
        );
      }
    } else {
      _due = DateTime.now().add(const Duration(days: 5));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _tag.dispose();
    _criterionInput.dispose();
    super.dispose();
  }

  void _addCriterion() {
    final text = _criterionInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _criteria.add(Criterion(text));
      _criterionInput.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = TeamsScope.of(context);
    if (!state.canCreateEditTasks(widget.teamId)) return;

    final tagValue = _tag.text.trim().isEmpty ? 'General' : _tag.text.trim();
    if (_isEdit) {
      final t = state.findTaskById(widget.taskId!);
      if (t == null) return;
      t.title = _title.text.trim();
      t.description = _desc.text.trim();
      t.tag = tagValue;
      t.priority = _priority;
      t.assignee = _assignee;
      t.dueDate = _due;
      t.criteria = _criteria;
      await state.saveTask(t);
    } else {
      final n = state.nextNumber();
      await state.saveTask(
        TaskItem(
          id: 'task-$n',
          teamId: widget.teamId,
          number: n,
          title: _title.text.trim(),
          description: _desc.text.trim(),
          tag: tagValue,
          priority: _priority,
          status: TaskStatus.todo,
          assignee: _assignee,
          dueDate: _due,
          criteria: _criteria,
        ),
      );
    }
    if (!mounted) return;
    showSnack(
      context,
      _isEdit ? 'Task updated' : 'Task created',
      type: AppFeedbackType.success,
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    if (!_isEdit) return;
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete task?', style: AppStyles.title17Bold(ctx)),
        content: Text(
          'This task will be permanently removed from the board.',
          style: AppStyles.body14Secondary(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppStyles.body14Secondary(ctx)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppStyles.body14Bold(ctx, color: c.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await TeamsScope.of(context).deleteTask(widget.teamId, widget.taskId!);
      if (!mounted) return;
      showSnack(context, 'Task deleted');
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null && mounted) setState(() => _due = d);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(widget.teamId);
    final canEdit = state.canCreateEditTasks(widget.teamId);
    final canAssign = state.canAssignTasks(widget.teamId);
    final canDelete = state.canDeleteTasks(widget.teamId);

    if (team == null || !canEdit) {
      return Scaffold(
        backgroundColor: c.surface,
        appBar: AppTopBar(_isEdit ? 'Edit Task' : 'Create Task'),
        body: Center(
          child: Text(
            'You do not have permission to create or edit tasks.',
            style: AppStyles.body14Secondary(context),
          ),
        ),
      );
    }

    final members = team.members;
    final existing = _isEdit ? state.findTaskById(widget.taskId!) : null;
    final number = existing?.number ?? state.peekNextNumber;
    final current = members.where((m) => m.id == _assignee?.id).firstOrNull;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppTopBar(
        _isEdit ? 'Edit Task' : 'Create Task',
        actions: [
          if (_isEdit && canDelete)
            IconButton(
              tooltip: 'Delete task',
              icon: Icon(Icons.delete_outline, size: 20, color: c.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.folder_outlined, size: 13, color: c.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${team.name}  •  TASK-$number',
                        style: AppStyles.body11Medium(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEdit ? 'Edit Task' : 'New Task',
                    style: AppStyles.h20(context),
                  ),
                  const SizedBox(height: 16),
                  AppInputField(
                    controller: _title,
                    label: 'Task Title',
                    trailingLabel: 'Required',
                    hint: 'What needs to be done?',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppInputField(
                    controller: _tag,
                    label: 'Tag',
                    trailingLabel: 'Optional',
                    hint: 'e.g. Architecture, UI/UX, Backend',
                  ),
                  const SizedBox(height: 14),
                  AppInputField(
                    controller: _desc,
                    label: 'Description',
                    trailingLabel: 'Markdown',
                    hint: 'Describe the task…',
                    maxLines: 5,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxDesc),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _label(context, 'Priority'),
                  TaskPrioritySelector(
                    selected: _priority,
                    onChanged: (p) => setState(() => _priority = p),
                  ),
                  if (canAssign) ...[
                    const SizedBox(height: 16),
                    AppDropdownField<Member?>(
                      label: 'Assignee',
                      hint: 'Unassigned',
                      value: current,
                      items: [null, ...members],
                      itemLabel: (m) => m?.name ?? 'Unassigned',
                      onChanged: (m) => setState(() => _assignee = m),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _label(context, 'Due Date'),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface,
                        border: Border.all(color: c.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: c.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _due == null ? 'Pick a date' : fmtDate(_due!),
                            style: AppStyles.body13Primary(context),
                          ),
                          const Spacer(),
                          if (_due != null)
                            Pill(relativeDays(_due!), fontSize: 9.5),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label(
                    context,
                    'Acceptance Criteria',
                    trailing: '${_criteria.length} items',
                  ),
                  TaskCriteriaEditor(
                    controller: _criterionInput,
                    criteria: _criteria,
                    onAdd: _addCriterion,
                    onRemove: (i) => setState(() => _criteria.removeAt(i)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              buttonText: 'Save Task',
              leadingIcon: Icons.check_circle_outline,
              isDisabled: false,
              onPressed: _save,
            ),
            const SizedBox(height: 10),
            AppSecondaryButton(
              buttonText: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text, {String? trailing}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(text, style: AppStyles.body12Bold(context)),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing,
              style: AppStyles.body11Medium(context, color: c.textSecondary),
            ),
        ],
      ),
    );
  }
}
