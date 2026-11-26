import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';

// Invitation summary card displayed in the Invited tab.
class InvitedProjectCard extends StatelessWidget {
  const InvitedProjectCard({
    super.key,
    required this.invitation,
    required this.onView,
  });

  final InvitationModel invitation;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, color, bg) = switch (invitation.status) {
      InvitationStatus.pending => ('Pending', c.warning, c.subtle(c.warning)),
      InvitationStatus.accepted => ('Accepted', c.success, c.subtle(c.success)),
      InvitationStatus.declined => ('Declined', c.error, c.subtle(c.error)),
    };

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invitation.projectName,
                  style: AppStyles.title16Bold(context),
                ),
              ),
              StatusChip(label: label, color: color, background: bg),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${invitation.ownerName} • ${invitation.ownerRole}',
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Offered role: ${invitation.role}',
            style: AppStyles.body13Primary(context),
          ),
          const SizedBox(height: 10),
          SkillWrap(invitation.skills),
          const SizedBox(height: 12),
          AppButton(label: 'View Invitation', outlined: true, onPressed: onView),
        ],
      ),
    );
  }
}
