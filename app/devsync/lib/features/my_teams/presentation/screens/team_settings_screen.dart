import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/widgets/common.dart';
import 'package:devsync/features/my_teams/presentation/widgets/settings/team_settings_sections.dart';
import 'package:flutter/material.dart';

// Owner-only settings screen for workspace info, permissions, workflow, and danger zone.
class TeamSettingsScreen extends StatefulWidget {
  const TeamSettingsScreen({super.key, required this.teamId});

  final String teamId;

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  late final TextEditingController _repoController;
  late final TextEditingController _sprintController;
  late final TextEditingController _versionController;
  DateTime? _targetEndDate;
  late TeamSettings _settings;
  int _selectedRoleTab = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _repoController = TextEditingController();
    _sprintController = TextEditingController();
    _versionController = TextEditingController();
    _settings = const TeamSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final team = TeamsScope.of(context).findTeamById(widget.teamId);
    if (team != null) {
      _repoController.text = team.repoUrl;
      _sprintController.text = team.sprint;
      _versionController.text = team.version;
      _targetEndDate = team.expectedEndDate;
      _settings = team.settings;
    }
  }

  @override
  void dispose() {
    _repoController.dispose();
    _sprintController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  RolePermissions get _activePerms => _selectedRoleTab == 0
      ? _settings.trackLeaderPermissions
      : _settings.memberPermissions;

  void _updateActivePerms(RolePermissions updated) {
    setState(() {
      _settings = _selectedRoleTab == 0
          ? _settings.copyWith(trackLeaderPermissions: updated)
          : _settings.copyWith(memberPermissions: updated);
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetEndDate ?? now.add(const Duration(days: 14)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) setState(() => _targetEndDate = picked);
  }

  Future<void> _saveSettings() async {
    await TeamsScope.of(context).updateTeamSettings(
      widget.teamId,
      repoUrl: _repoController.text.trim(),
      sprint: _sprintController.text.trim().isEmpty
          ? 'Active Sprint'
          : _sprintController.text.trim(),
      version: _versionController.text.trim().isEmpty
          ? 'v1.0.0'
          : _versionController.text.trim(),
      expectedEndDate: _targetEndDate,
      settings: _settings,
    );
    if (!mounted) return;
    showSnack(context, 'Team settings saved', type: AppFeedbackType.success);
    Navigator.of(context).pop();
  }

  Future<void> _transferOwnership(Team team) async {
    final c = context.colors;
    final candidates = team.members.where((m) => !m.isOwner).toList();
    if (candidates.isEmpty) {
      showSnack(context, 'Add another member before transferring ownership.');
      return;
    }

    final selected = await showModalBottomSheet<Member>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select New Project Owner',
                style: AppStyles.title16Bold(ctx),
              ),
            ),
            for (final m in candidates)
              ListTile(
                leading: Avatar(m.initials, size: 36),
                title: Text(m.name, style: AppStyles.body14Bold(ctx)),
                subtitle: Text(
                  '${m.effectiveRole.label} • ${m.role}',
                  style: AppStyles.body12Secondary(ctx),
                ),
                onTap: () => Navigator.pop(ctx, m),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Transfer ownership?', style: AppStyles.title17Bold(ctx)),
        content: Text(
          '${selected.name} will become the new Project Owner of "${team.name}". You will step down from Owner to Track Leader and lose access to Team Settings.',
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
              'Transfer',
              style: AppStyles.body14Bold(ctx, color: c.warning),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await TeamsScope.of(context).transferOwnership(team.id, selected.id);
      if (!mounted) return;
      showSnack(
        context,
        'Ownership transferred to ${selected.name}',
        type: AppFeedbackType.success,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDeleteTeam(Team team) async {
    final c = context.colors;
    if (team.members.any((m) => !m.isOwner)) {
      final goTransfer = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: c.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Transfer ownership first',
            style: AppStyles.title17Bold(ctx),
          ),
          content: Text(
            '"${team.name}" still has other active members. Transfer ownership to another member before stepping away, or remove other members first to delete the workspace.',
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
                'Transfer Ownership',
                style: AppStyles.body14Bold(ctx, color: c.primary),
              ),
            ),
          ],
        ),
      );
      if (goTransfer == true && mounted) await _transferOwnership(team);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete team?', style: AppStyles.title17Bold(ctx)),
        content: Text(
          'This will permanently delete "${team.name}" and all of its tasks.',
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
              'Delete Team',
              style: AppStyles.body14Bold(ctx, color: c.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await TeamsScope.of(context).deleteTeam(team.id);
      if (!mounted) return;
      showSnack(context, 'Team "${team.name}" deleted');
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = TeamsScope.of(context);
    final team = state.findTeamById(widget.teamId);

    if (team == null || !state.isOwnerOf(widget.teamId)) {
      return Scaffold(
        backgroundColor: c.surface,
        appBar: const AppTopBar('Team Settings'),
        body: Center(
          child: Text(
            'Only the Project Owner can access Team Settings.',
            style: AppStyles.body14Secondary(context),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.surface,
      appBar: const AppTopBar('Team Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const SectionHeader('WORKSPACE DETAILS'),
          WorkspaceDetailsSection(
            repoController: _repoController,
            sprintController: _sprintController,
            versionController: _versionController,
            targetEndDate: _targetEndDate,
            onPickEndDate: _pickEndDate,
          ),
          const SizedBox(height: 18),
          const SectionHeader('ROLE PERMISSIONS', trailing: 'Owner has all'),
          RolePermissionsSection(
            selectedRoleTab: _selectedRoleTab,
            permissions: _activePerms,
            onRoleTabChanged: (i) => setState(() => _selectedRoleTab = i),
            onPermissionsChanged: _updateActivePerms,
          ),
          const SizedBox(height: 18),
          const SectionHeader('WORKFLOW & ACCESS RULES'),
          WorkflowRulesSection(
            settings: _settings,
            onChanged: (updated) => setState(() => _settings = updated),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            buttonText: 'Save Settings',
            leadingIcon: Icons.check_circle_outline,
            isDisabled: false,
            onPressed: _saveSettings,
          ),
          const SizedBox(height: 22),
          const SectionHeader('DANGER ZONE'),
          DangerZoneSection(
            onTransferOwnership: () => _transferOwnership(team),
            onDeleteTeam: () => _confirmDeleteTeam(team),
          ),
        ],
      ),
    );
  }
}
