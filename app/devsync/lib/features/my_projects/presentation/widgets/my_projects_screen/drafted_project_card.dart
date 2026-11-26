import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';

// Saved draft project card displayed in the Drafted tab.
class DraftedProjectCard extends StatelessWidget {
  const DraftedProjectCard({
    super.key,
    required this.project,
    required this.onPublish,
    required this.onDelete,
    this.onTap,
  });

  final ProjectModel project;
  final VoidCallback onPublish;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: AppStyles.title16Bold(context),
                ),
              ),
              StatusChip(
                label: 'Draft',
                color: c.warning,
                background: c.subtle(c.warning),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.description.isEmpty
                ? 'No description added yet.'
                : project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body12Secondary(context),
          ),
          if (project.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            SkillWrap(project.tags),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Delete',
                  outlined: true,
                  color: c.error,
                  onPressed: onDelete,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(label: 'Publish', onPressed: onPublish),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
