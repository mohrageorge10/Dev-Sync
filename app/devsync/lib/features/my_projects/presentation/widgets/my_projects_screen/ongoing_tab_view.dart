import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../data/models/project_model.dart';
import 'empty_view.dart';
import 'ongoing_project_card.dart';

enum _OngoingRoleFilter { all, owner, member }

// Filterable list of ongoing projects (All / Owner / Member).
class OngoingTabView extends StatefulWidget {
  const OngoingTabView({
    super.key,
    required this.projects,
    required this.onRefresh,
    required this.onTapProject,
  });

  final List<ProjectModel> projects;
  final Future<void> Function() onRefresh;
  final void Function(ProjectModel project) onTapProject;

  @override
  State<OngoingTabView> createState() => _OngoingTabViewState();
}

class _OngoingTabViewState extends State<OngoingTabView> {
  _OngoingRoleFilter _filter = _OngoingRoleFilter.all;

  List<ProjectModel> get _filtered => switch (_filter) {
        _OngoingRoleFilter.all => widget.projects,
        _OngoingRoleFilter.owner =>
          widget.projects.where((p) => p.isOwner).toList(),
        _OngoingRoleFilter.member =>
          widget.projects.where((p) => !p.isOwner).toList(),
      };

  int _countFor(_OngoingRoleFilter filter) => switch (filter) {
        _OngoingRoleFilter.all => widget.projects.length,
        _OngoingRoleFilter.owner =>
          widget.projects.where((p) => p.isOwner).length,
        _OngoingRoleFilter.member =>
          widget.projects.where((p) => !p.isOwner).length,
      };

  String get _emptyMessage => switch (_filter) {
        _OngoingRoleFilter.owner => 'No owned projects yet',
        _OngoingRoleFilter.member => 'No joined projects yet',
        _OngoingRoleFilter.all => 'No ongoing projects',
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
              _RoleFilterChip(
                label: 'All (${_countFor(_OngoingRoleFilter.all)})',
                selected: _filter == _OngoingRoleFilter.all,
                accentColor: c.primary,
                onTap: () => setState(() => _filter = _OngoingRoleFilter.all),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: 'Owner (${_countFor(_OngoingRoleFilter.owner)})',
                selected: _filter == _OngoingRoleFilter.owner,
                accentColor: c.primary,
                onTap: () => setState(() => _filter = _OngoingRoleFilter.owner),
              ),
              const SizedBox(width: 8),
              _RoleFilterChip(
                label: 'Member (${_countFor(_OngoingRoleFilter.member)})',
                selected: _filter == _OngoingRoleFilter.member,
                accentColor: c.success,
                onTap: () =>
                    setState(() => _filter = _OngoingRoleFilter.member),
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
                          (p) => OngoingProjectCard(
                            project: p,
                            onTap: () => widget.onTapProject(p),
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

class _RoleFilterChip extends StatelessWidget {
  const _RoleFilterChip({
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
