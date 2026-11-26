import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/invitation_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/invitation_details_screen/invitation_header_card.dart';
import '../widgets/invitation_details_screen/offered_role_card.dart';

// Screen showing project invitation details with Accept and Decline actions.
class InvitationDetailsScreen extends StatelessWidget {
  const InvitationDetailsScreen({super.key, required this.invitation});

  final InvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<MyProjectsCubit>();
    final isPending = invitation.status == InvitationStatus.pending;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Invitation Details',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InvitationHeaderCard(invitation: invitation),
          OfferedRoleCard(invitation: invitation),
          if (isPending) ...[
            const SizedBox(height: 8),
            AppButton(
              label: 'Accept Invitation',
              onPressed: () {
                cubit.respondToInvitation(invitation.id, true);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Decline Invitation',
              outlined: true,
              color: c.error,
              onPressed: () {
                cubit.respondToInvitation(invitation.id, false);
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
