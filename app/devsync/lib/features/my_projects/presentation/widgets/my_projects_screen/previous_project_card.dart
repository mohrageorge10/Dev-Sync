import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../status_chip.dart';

// Completed or archived project card displayed in the Previous tab.
class PreviousProjectCard extends StatelessWidget {
  const PreviousProjectCard({
    super.key,
    required this.project,
    required this.onView,
  });

  final ProjectModel project;
  final VoidCallback onView;

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
                child: Text(
                  project.name,
                  style: AppStyles.title16Bold(context),
                ),
              ),
              StatusChip(
                label: project.statusText,
                color: c.success,
                background: c.subtle(c.success),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (project.period.isNotEmpty)
            Text(project.period, style: AppStyles.body12Secondary(context)),
          const SizedBox(height: 4),
          Text(project.description, style: AppStyles.body13Primary(context)),
          const SizedBox(height: 12),
          AppButton(label: 'View Project', outlined: true, onPressed: onView),
        ],
      ),
    );
  }
}
