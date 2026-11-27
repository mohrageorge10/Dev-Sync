import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

import '../../../data/models/my_application_model.dart';
import 'applied_project_card.dart';
import 'empty_view.dart';

// Filterable list of projects the current user applied to (All / Accepted / Pending / Declined).
class AppliedTabView extends StatefulWidget {
  const AppliedTabView({
    super.key,
    required this.applications,
    required this.onRefresh,
    required this.onWithdraw,
    required this.onOpenWorkspace,
  });

  final List<MyApplicationModel> applications;
  final Future<void> Function() onRefresh;
  final void Function(MyApplicationModel app) onWithdraw;
  final void Function(MyApplicationModel app) onOpenWorkspace;

  @override
  State<AppliedTabView> createState() => _AppliedTabViewState();
}

class _AppliedTabViewState extends State<AppliedTabView> {
  ApplicationStatus? _selectedStatus;

  List<MyApplicationModel> get _filtered {
    if (_selectedStatus == null) return widget.applications;
    return widget.applications
        .where((a) => a.status == _selectedStatus)
        .toList();
  }

  int _countFor(ApplicationStatus? status) {
    if (status == null) return widget.applications.length;
    return widget.applications.where((a) => a.status == status).length;
  }

  String get _emptyMessage => switch (_selectedStatus) {
        ApplicationStatus.accepted => 'No accepted applications yet',
        ApplicationStatus.pending => 'No pending applications',
        ApplicationStatus.declined => 'No declined applications',
        null => 'No applications sent yet',
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
              _FilterChip(
                label: 'All (${_countFor(null)})',
                selected: _selectedStatus == null,
                accentColor: c.primary,
                onTap: () => setState(() => _selectedStatus = null),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Accepted (${_countFor(ApplicationStatus.accepted)})',
                selected: _selectedStatus == ApplicationStatus.accepted,
                accentColor: c.success,
                onTap: () =>
                    setState(() => _selectedStatus = ApplicationStatus.accepted),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pending (${_countFor(ApplicationStatus.pending)})',
                selected: _selectedStatus == ApplicationStatus.pending,
                accentColor: c.warning,
                onTap: () =>
                    setState(() => _selectedStatus = ApplicationStatus.pending),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Declined (${_countFor(ApplicationStatus.declined)})',
                selected: _selectedStatus == ApplicationStatus.declined,
                accentColor: c.error,
                onTap: () =>
                    setState(() => _selectedStatus = ApplicationStatus.declined),
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
                          (app) => AppliedProjectCard(
                            application: app,
                            onWithdraw: () => widget.onWithdraw(app),
                            onOpenWorkspace: () => widget.onOpenWorkspace(app),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          color: selected ? accentColor.withValues(alpha: 0.14) : c.backgroundPrimary,
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
