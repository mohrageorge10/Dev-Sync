import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../data/models/project_model.dart';
import 'empty_view.dart';
import 'previous_project_card.dart';

// Filterable list of previous projects (All / Product / Done / Archived).
class PreviousTabView extends StatefulWidget {
  const PreviousTabView({
    super.key,
    required this.projects,
    required this.onRefresh,
    required this.onViewProject,
  });

  final List<ProjectModel> projects;
  final Future<void> Function() onRefresh;
  final void Function(ProjectModel project) onViewProject;

  @override
  State<PreviousTabView> createState() => _PreviousTabViewState();
}

class _PreviousTabViewState extends State<PreviousTabView> {
  ProjectOutcome? _selected;

  ProjectOutcome _effectiveOutcome(ProjectModel p) {
    if (p.outcome != null) return p.outcome!;
    final lower = p.statusText.toLowerCase();
    if (lower.contains('shipped') || lower.contains('product')) {
      return ProjectOutcome.shipped;
    }
    if (lower.contains('archived')) return ProjectOutcome.archived;
    return ProjectOutcome.completed;
  }

  List<ProjectModel> get _filtered {
    if (_selected == null) return widget.projects;
    return widget.projects
        .where((p) => _effectiveOutcome(p) == _selected)
        .toList();
  }

  int _countFor(ProjectOutcome? outcome) {
    if (outcome == null) return widget.projects.length;
    return widget.projects.where((p) => _effectiveOutcome(p) == outcome).length;
  }

  String get _emptyMessage => switch (_selected) {
        ProjectOutcome.shipped => 'No shipped products yet',
        ProjectOutcome.completed => 'No completed projects yet',
        ProjectOutcome.archived => 'No archived projects',
        null => 'No previous projects',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filtered = _filtered;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            children: [
              _PreviousFilterChip(
                label: 'All (${_countFor(null)})',
                selected: _selected == null,
                accentColor: c.primary,
                onTap: () => setState(() => _selected = null),
              ),
              const SizedBox(width: 8),
              _PreviousFilterChip(
                label: 'Product (${_countFor(ProjectOutcome.shipped)})',
                selected: _selected == ProjectOutcome.shipped,
                accentColor: c.primary,
                onTap: () =>
                    setState(() => _selected = ProjectOutcome.shipped),
              ),
              const SizedBox(width: 8),
              _PreviousFilterChip(
                label: 'Done (${_countFor(ProjectOutcome.completed)})',
                selected: _selected == ProjectOutcome.completed,
                accentColor: c.success,
                onTap: () =>
                    setState(() => _selected = ProjectOutcome.completed),
              ),
              const SizedBox(width: 8),
              _PreviousFilterChip(
                label: 'Archived (${_countFor(ProjectOutcome.archived)})',
                selected: _selected == ProjectOutcome.archived,
                accentColor: c.textSecondary,
                onTap: () =>
                    setState(() => _selected = ProjectOutcome.archived),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 100),
                      EmptyView(_emptyMessage),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
                    children: filtered
                        .map(
                          (p) => PreviousProjectCard(
                            project: p,
                            onView: () => widget.onViewProject(p),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PreviousFilterChip extends StatelessWidget {
  const _PreviousFilterChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.14)
              : c.backgroundPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : c.border,
          ),
        ),
        child: Text(
          label,
          style: AppStyles.body12Medium(
            context,
            color: selected ? accentColor : c.textSecondary,
          ).copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
