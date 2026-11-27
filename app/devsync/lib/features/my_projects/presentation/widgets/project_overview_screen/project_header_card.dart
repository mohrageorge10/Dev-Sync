import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/project_model.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';

// Project overview header card showing title, unique code, status, description, and tags.
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
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                project.statusText,
                style: AppStyles.body12SemiBold(context, color: c.success),
              ),
              if (project.projectCode.isNotEmpty) ...[
                const SizedBox(width: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: project.projectCode));
                    AppFeedback.show(
                      context,
                      message: 'Project ID ${project.projectCode} copied',
                      type: AppFeedbackType.success,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '#${project.projectCode}',
                          style: AppStyles.caption10Bold(
                            context,
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy_rounded,
                          size: 11,
                          color: c.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
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
