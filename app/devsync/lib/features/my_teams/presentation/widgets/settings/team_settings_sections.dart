import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/date_format_utils.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/widgets/common.dart';
import 'package:flutter/material.dart';

// Workspace metadata form card (repo, sprint, version, end date).
class WorkspaceDetailsSection extends StatelessWidget {
  const WorkspaceDetailsSection({
    super.key,
    required this.repoController,
    required this.sprintController,
    required this.versionController,
    required this.targetEndDate,
    required this.onPickEndDate,
  });

  final TextEditingController repoController;
  final TextEditingController sprintController;
  final TextEditingController versionController;
  final DateTime? targetEndDate;
  final VoidCallback onPickEndDate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputField(
            controller: repoController,
            label: 'Code Repository URL',
            hint: 'https://github.com/org/repo',
            prefixIcon: Icons.link_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppInputField(
                  controller: sprintController,
                  label: 'Current Sprint',
                  hint: 'Sprint 2',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppInputField(
                  controller: versionController,
                  label: 'Version',
                  hint: 'v1.0.0',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Target End Date', style: AppStyles.body12Bold(context)),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPickEndDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
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
                    targetEndDate == null
                        ? 'Pick target end date'
                        : fmtDate(targetEndDate!),
                    style: AppStyles.body13Primary(context),
                  ),
                  const Spacer(),
                  if (targetEndDate != null)
                    Pill(relativeDays(targetEndDate!), fontSize: 9.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Role permissions matrix for Track Leader and Member roles.
class RolePermissionsSection extends StatelessWidget {
  const RolePermissionsSection({
    super.key,
    required this.selectedRoleTab,
    required this.permissions,
    required this.onRoleTabChanged,
    required this.onPermissionsChanged,
  });

  final int selectedRoleTab;
  final RolePermissions permissions;
  final ValueChanged<int> onRoleTabChanged;
  final ValueChanged<RolePermissions> onPermissionsChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSegmentedControl(
            labels: const ['Track Leader', 'Member'],
            selectedIndex: selectedRoleTab,
            onChanged: onRoleTabChanged,
          ),
          const SizedBox(height: 12),
          SettingsSwitchRow(
            title: 'Create & Edit Tasks',
            subtitle: 'Add new tasks and update task details',
            value: permissions.createEditTasks,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(createEditTasks: v)),
          ),
          SettingsSwitchRow(
            title: 'Assign Tasks',
            subtitle: 'Assign or reassign tasks to team members',
            value: permissions.assignTasks,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(assignTasks: v)),
          ),
          SettingsSwitchRow(
            title: 'Delete Tasks',
            subtitle: 'Permanently remove tasks from the board',
            value: permissions.deleteTasks,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(deleteTasks: v)),
          ),
          SettingsSwitchRow(
            title: 'Approve Tasks (In Review → Done)',
            subtitle: 'Review PRs and mark tasks completed',
            value: permissions.approveTasks,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(approveTasks: v)),
          ),
          SettingsSwitchRow(
            title: 'Invite Members',
            subtitle: 'Scout and invite new developers to the team',
            value: permissions.inviteMembers,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(inviteMembers: v)),
          ),
          SettingsSwitchRow(
            title: 'View All Team Tasks',
            subtitle: 'See full board & unassigned backlog',
            value: permissions.viewAllTasks,
            showDivider: false,
            onChanged: (v) =>
                onPermissionsChanged(permissions.copyWith(viewAllTasks: v)),
          ),
        ],
      ),
    );
  }
}

// Workflow and membership access rules card.
class WorkflowRulesSection extends StatelessWidget {
  const WorkflowRulesSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final TeamSettings settings;
  final ValueChanged<TeamSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          SettingsSwitchRow(
            title: 'Require Push / PR Check',
            subtitle: 'Prompt members to confirm PR before moving to In Review',
            value: settings.requirePrCheck,
            onChanged: (v) => onChanged(settings.copyWith(requirePrCheck: v)),
          ),
          SettingsSwitchRow(
            title: 'Invite-Only Membership',
            subtitle: settings.inviteOnly
                ? 'Only invited developers can join'
                : 'Open for applications from Discover',
            value: settings.inviteOnly,
            showDivider: false,
            onChanged: (v) => onChanged(settings.copyWith(inviteOnly: v)),
          ),
        ],
      ),
    );
  }
}

// Danger zone card for ownership transfer and team deletion.
class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({
    super.key,
    required this.onTransferOwnership,
    required this.onDeleteTeam,
  });

  final VoidCallback onTransferOwnership;
  final VoidCallback onDeleteTeam;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      borderColor: c.error.withValues(alpha: 0.35),
      child: Column(
        children: [
          _DangerActionTile(
            icon: Icons.swap_horiz_rounded,
            color: c.warning,
            title: 'Transfer Ownership',
            subtitle:
                'Hand over Owner rights to another member (you step down to Track Leader)',
            onTap: onTransferOwnership,
          ),
          Divider(height: 18, color: c.border),
          _DangerActionTile(
            icon: Icons.delete_outline_rounded,
            color: c.error,
            title: 'Delete Team',
            subtitle: 'Permanently delete workspace and all tasks',
            onTap: onDeleteTeam,
          ),
        ],
      ),
    );
  }
}

// Reusable toggle row used in team settings cards.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppStyles.body13Bold(context)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppStyles.body11Secondary(context)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: value,
                activeTrackColor: c.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: c.border),
      ],
    );
  }
}

class _DangerActionTile extends StatelessWidget {
  const _DangerActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.subtle(color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body13Bold(context, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppStyles.body11Secondary(context)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 18, color: color),
        ],
      ),
    );
  }
}
