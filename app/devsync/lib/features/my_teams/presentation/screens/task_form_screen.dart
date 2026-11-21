import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/app_state.dart';
import '../../data/models/models.dart';
import '../widgets/common.dart';

// Screen for creating or editing a task
class TaskFormScreen extends StatefulWidget {
  final String teamId;
  final String? taskId;
  const TaskFormScreen({super.key, required this.teamId, this.taskId});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _desc;
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (_isEdit) {
      final t = AppScope.of(context).taskById(widget.taskId!);
      _title.text = t.title;
      _desc.text = t.description;
      _priority = t.priority;
      _assignee = t.assignee;
      _due = t.dueDate;
    } else {
      _due = DateTime.now().add(const Duration(days: 5));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = AppScope.of(context);
    if (_isEdit) {
      final t = state.taskById(widget.taskId!);
      t.title = _title.text.trim();
      t.description = _desc.text.trim();
      t.priority = _priority;
      t.assignee = _assignee;
      t.dueDate = _due;
      state.saveTask(t);
    } else {
      final n = state.nextNumber();
      state.saveTask(TaskItem(
        id: 'task-$n',
        teamId: widget.teamId,
        number: n,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        priority: _priority,
        assignee: _assignee,
        dueDate: _due,
      ));
    }
    Navigator.of(context).pop();
    showSnack(context, _isEdit ? 'Task updated' : 'Task created');
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _due = d);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final team = state.teamById(widget.teamId);
    final members = team.members;
    final number = _isEdit
        ? state.taskById(widget.taskId!).number
        : state.peekNextNumber;
    // Find currently selected member within team members
    final current = members.where((m) => m.id == _assignee?.id).firstOrNull;

    return Scaffold(
      appBar: AppTopBar(_isEdit ? 'Create Or Edit Task' : 'Create Task'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.folder_outlined,
                          size: 13, color: AppPalette.primary),
                      const SizedBox(width: 4),
                      Text('${team.name}  •  TASK-$number',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppPalette.primary)),
                    ]),
                    const SizedBox(height: 4),
                    Text(_isEdit ? 'Edit Task' : 'New Task',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _title,
                      label: 'Task Title',
                      trailingLabel: 'Required',
                      hint: 'What needs to be done?',
                      validator: (v) => (v.trim().isEmpty) ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _desc,
                      label: 'Description',
                      trailingLabel: 'Markdown Preview',
                      hint: 'Describe the task…',
                      maxLines: 6,
                      inputFormatters: [LengthLimitingTextInputFormatter(_maxDesc)],
                    ),
                    const SizedBox(height: 12),
                    _label('Priority'),
                    Row(children: [
                      for (final p in Priority.values) ...[
                        Expanded(
                          child: _PriorityOption(
                            priority: p,
                            selected: _priority == p,
                            onTap: () => setState(() => _priority = p),
                          ),
                        ),
                        if (p != Priority.high) const SizedBox(width: 8),
                      ],
                    ]),
                    const SizedBox(height: 16),
                    AppDropdownField<Member?>(
                      label: 'Assignee',
                      hint: 'Unassigned',
                      value: current,
                      items: [null, ...members],
                      itemLabel: (m) => m?.name ?? 'Unassigned',
                      onChanged: (m) => setState(() => _assignee = m),
                    ),
                    const SizedBox(height: 16),
                    _label('Due Date'),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                            color: AppPalette.fieldBg,
                            border: Border.all(color: AppPalette.border),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 16, color: AppPalette.primary),
                          const SizedBox(width: 8),
                          Text(_due == null ? 'Pick a date' : fmtDate(_due!),
                              style: const TextStyle(fontSize: 12.5)),
                          const Spacer(),
                          if (_due != null)
                            Pill(relativeDays(_due!), fontSize: 9.5),
                        ]),
                      ),
                    ),
                  ]),
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

  Widget _label(String text, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text(text,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (trailing != null)
            Text(trailing,
                style: TextStyle(
                    fontSize: 10,
                    color: trailing == 'Markdown Preview'
                        ? AppPalette.primary
                        : AppPalette.muted)),
        ]),
      );
}

class _PriorityOption extends StatelessWidget {
  final Priority priority;
  final bool selected;
  final VoidCallback onTap;
  const _PriorityOption(
      {required this.priority, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHigh = priority == Priority.high;
    final fg = selected
        ? (isHigh ? AppPalette.danger : AppPalette.primary)
        : AppPalette.muted;
    final bg = selected
        ? (isHigh ? AppPalette.dangerBg : AppPalette.softBlue)
        : AppPalette.fieldBg;
    final icon = switch (priority) {
      Priority.low => Icons.keyboard_double_arrow_down,
      Priority.medium => Icons.drag_handle,
      Priority.high => Icons.priority_high,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(priority.label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ]),
      ),
    );
  }
}
