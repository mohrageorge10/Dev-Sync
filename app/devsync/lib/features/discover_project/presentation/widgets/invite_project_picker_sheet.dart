import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:flutter/material.dart';

// Bottom sheet allowing project owners to pick an eligible owned project to invite a developer to.
class InviteProjectPickerSheet extends StatelessWidget {
  const InviteProjectPickerSheet({
    super.key,
    required this.developer,
    required this.eligibleProjects,
    required this.hasAnyOwnedProjects,
    required this.onSelected,
  });

  final DeveloperModel developer;
  final List<ProjectModel> eligibleProjects;
  final bool hasAnyOwnedProjects;
  final ValueChanged<ProjectModel> onSelected;

  static Future<void> show(
    BuildContext context, {
    required DeveloperModel developer,
    required List<ProjectModel> eligibleProjects,
    required bool hasAnyOwnedProjects,
    required ValueChanged<ProjectModel> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => InviteProjectPickerSheet(
        developer: developer,
        eligibleProjects: eligibleProjects,
        hasAnyOwnedProjects: hasAnyOwnedProjects,
        onSelected: (project) {
          Navigator.pop(sheetContext);
          onSelected(project);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Invite ${developer.name}',
              style: AppStyles.h3(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Select one of your open projects matching ${developer.role} or their skills.',
              style: AppStyles.body12Secondary(context),
            ),
            const SizedBox(height: 16),
            if (eligibleProjects.isEmpty)
              _EmptyEligibleOwnedProjects(
                developer: developer,
                hasAnyOwnedProjects: hasAnyOwnedProjects,
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: eligibleProjects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final project = eligibleProjects[i];
                    return _OwnedProjectTile(
                      project: project,
                      onTap: () => onSelected(project),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OwnedProjectTile extends StatelessWidget {
  const _OwnedProjectTile({
    required this.project,
    required this.onTap,
  });

  final ProjectModel project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(project.icon, color: c.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.title15Bold(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open: ${project.needs} • ${project.members}/${project.maxMembers}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.body12Secondary(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppBadge.info(context, 'Invite'),
          ],
        ),
      ),
    );
  }
}

class _EmptyEligibleOwnedProjects extends StatelessWidget {
  const _EmptyEligibleOwnedProjects({
    required this.developer,
    required this.hasAnyOwnedProjects,
  });

  final DeveloperModel developer;
  final bool hasAnyOwnedProjects;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 32, color: c.textSecondary),
          const SizedBox(height: 10),
          Text(
            hasAnyOwnedProjects
                ? 'No matching open projects'
                : "You don't own any open projects yet",
            textAlign: TextAlign.center,
            style: AppStyles.body14Bold(context),
          ),
          const SizedBox(height: 4),
          Text(
            hasAnyOwnedProjects
                ? 'None of your open projects currently need ${developer.role} or match ${developer.name}\'s skills.'
                : 'Create a project with an open slot for ${developer.role} or matching skills to invite ${developer.name}.',
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              buttonText: 'Create Project',
              leadingIcon: Icons.add_rounded,
              isDisabled: false,
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.createProject);
              },
            ),
          ),
        ],
      ),
    );
  }
}
