import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/invitation_model.dart';
import '../section_card.dart';
import '../user_avatar.dart';

// Header card displaying project title, inviter info, and personal note.
class InvitationHeaderCard extends StatelessWidget {
  const InvitationHeaderCard({super.key, required this.invitation});

  final InvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(invitation.projectName, style: AppStyles.h20(context)),
          const SizedBox(height: 10),
          Row(
            children: [
              UserAvatar(name: invitation.ownerName, radius: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${invitation.ownerName} • ${invitation.ownerRole}',
                  style: AppStyles.body12Secondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${invitation.note}"',
            style: AppStyles.body13Secondary(
              context,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
