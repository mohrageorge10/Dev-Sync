import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';

// Project overview header card showing title, status, description, and tags.
class ProjectHeaderCard extends StatelessWidget {
  const ProjectHeaderCard({super.key, required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(project.name, style: AppStyles.h20(context)),
              ),
              StatusChip(label: project.isOwner ? 'Owner' : 'Member'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            project.statusText,
            style: AppStyles.body12SemiBold(context, color: c.success),
          ),
          const SizedBox(height: 10),
          Text(project.description, style: AppStyles.body13Primary(context)),
          const SizedBox(height: 10),
          SkillWrap(project.tags),
        ],
      ),
    );
  }
}
