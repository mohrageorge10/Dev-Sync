import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/applicant_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';
import '../user_avatar.dart';

// Incoming join request card in the requests list.
class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.applicant,
    required this.onReview,
  });

  final ApplicantModel applicant;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: applicant.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.name, style: AppStyles.body14Bold(context)),
                    Text(
                      applicant.location,
                      style: AppStyles.body12Secondary(context),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: '${applicant.matchPercent}% Fit',
                color: c.success,
                background: c.subtle(c.success),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Applying for: ${applicant.position}',
            style: AppStyles.body13Primary(context),
          ),
          const SizedBox(height: 8),
          SkillWrap(applicant.skills),
          const SizedBox(height: 12),
          AppButton(
            label: 'Review Application',
            outlined: true,
            onPressed: onReview,
          ),
        ],
      ),
    );
  }
}
