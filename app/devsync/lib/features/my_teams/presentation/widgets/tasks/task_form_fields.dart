import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:flutter/material.dart';

// Horizontal priority picker (Low / Medium / High).
class TaskPrioritySelector extends StatelessWidget {
  const TaskPrioritySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Priority selected;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final p in Priority.values) ...[
          Expanded(
            child: _PriorityOption(
              priority: p,
              selected: selected == p,
              onTap: () => onChanged(p),
            ),
          ),
          if (p != Priority.high) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  const _PriorityOption({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final Priority priority;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isHigh = priority == Priority.high;
    final fg = selected ? (isHigh ? c.error : c.primary) : c.textSecondary;
    final bg = selected
        ? (isHigh ? c.subtle(c.error) : c.subtleBlueSurface)
        : c.surface;
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
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
            Text(
              priority.label,
              style: AppStyles.body12SemiBold(context, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline checklist editor for task acceptance criteria.
class TaskCriteriaEditor extends StatelessWidget {
  const TaskCriteriaEditor({
    super.key,
    required this.controller,
    required this.criteria,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<Criterion> criteria;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppStyles.body13Primary(context),
                onSubmitted: (_) => onAdd(),
                decoration: InputDecoration(
                  hintText: 'Add a checklist item...',
                  hintStyle: AppStyles.body12Secondary(context),
                  filled: true,
                  fillColor: c.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              style: IconButton.styleFrom(
                backgroundColor: c.subtleBlueSurface,
                foregroundColor: c.primary,
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
            ),
          ],
        ),
        if (criteria.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (var i = 0; i < criteria.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 16,
                    color: c.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      criteria[i].text,
                      style: AppStyles.body12Primary(context),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: c.textSecondary,
                    ),
                    onPressed: () => onRemove(i),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
