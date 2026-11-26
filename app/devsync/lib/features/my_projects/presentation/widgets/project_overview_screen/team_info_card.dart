import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card summarizing team headcount and open positions.
class TeamInfoCard extends StatelessWidget {
  const TeamInfoCard({super.key, required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Team'),
          Text(
            '${project.membersCount} of ${project.totalSeats} members',
            style: AppStyles.body13Primary(context),
          ),
          const SizedBox(height: 8),
          const SectionTitle('Open positions'),
          if (project.openRoles.isEmpty)
            Text('No open roles', style: AppStyles.body12Secondary(context))
          else
            ...project.openRoles.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $r', style: AppStyles.body13Primary(context)),
              ),
            ),
        ],
      ),
    );
  }
}
