import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../section_card.dart';
import '../section_title.dart';
import '../skill_chip.dart';

// Card showing offered role details, hours, responsibilities, and skills.
class OfferedRoleCard extends StatelessWidget {
  const OfferedRoleCard({super.key, required this.invitation});

  final InvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Offered Position'),
          Text(invitation.role, style: AppStyles.title16Bold(context)),
          const SizedBox(height: 6),
          Text(
            '${invitation.hoursPerWeek}  •  ${invitation.level}',
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 12),
          const SectionTitle('Responsibilities'),
          ...invitation.responsibilities.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $r', style: AppStyles.body13Primary(context)),
            ),
          ),
          const SizedBox(height: 12),
          const SectionTitle('Skills'),
          SkillWrap(invitation.skills),
        ],
      ),
    );
  }
}
