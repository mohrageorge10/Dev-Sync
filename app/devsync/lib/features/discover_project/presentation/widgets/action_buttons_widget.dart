import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:flutter/material.dart';

// Bottom action bar with Message and Invite buttons.
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onMessagePressed;
  final VoidCallback? onInvitePressed;
  final bool isInvited;

  const ActionButtonsWidget({
    super.key,
    this.onMessagePressed,
    this.onInvitePressed,
    this.isInvited = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppSecondaryButton(
            buttonText: 'Message',
            leadingIcon: Icons.chat_bubble_outline_rounded,
            onPressed: onMessagePressed ?? () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppPrimaryButton(
            buttonText: isInvited ? 'Invited' : 'Invite',
            leadingIcon: isInvited
                ? Icons.check_rounded
                : Icons.person_add_alt_1_outlined,
            isDisabled: isInvited,
            onPressed: onInvitePressed ?? () {},
          ),
        ),
      ],
    );
  }
}