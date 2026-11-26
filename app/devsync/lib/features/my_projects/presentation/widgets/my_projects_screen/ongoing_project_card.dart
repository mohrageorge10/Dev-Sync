import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../section_card.dart';
import '../status_chip.dart';

// Active project card displayed in the Ongoing tab.
class OngoingProjectCard extends StatelessWidget {
  const OngoingProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final ProjectModel project;
  final VoidCallback onTap;

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
                label: project.isOwner ? 'Owner' : 'Member',
                color: project.isOwner ? c.primary : c.textSecondary,
                background: project.isOwner ? c.subtleBlueSurface : c.surface,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(project.statusText, style: AppStyles.body12Secondary(context)),
          const SizedBox(height: 10),
          Text(
            '${project.membersCount} of ${project.totalSeats} members',
            style: AppStyles.body13Primary(context),
          ),
          if (project.openRoles.isNotEmpty)
            Text(
              '${project.openRoles.length} open role(s)',
              style: AppStyles.body12SemiBold(context, color: c.warning),
            ),
        ],
      ),
    );
  }
}
