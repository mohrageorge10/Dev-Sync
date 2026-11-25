import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Sticky footer with Back and Continue buttons for profile setup steps.
class ProfileStepFooter extends StatelessWidget {
  const ProfileStepFooter({
    super.key,
    required this.onContinue,
    this.blockedReason,
    this.continueLabel = 'Continue',
    this.showBack = true,
  });

  final VoidCallback onContinue;
  final String? blockedReason;
  final String continueLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        if (showBack && Navigator.canPop(context)) ...[
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.surface,
                  foregroundColor: c.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text('Back', style: AppStyles.body14Bold(context)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: 3,
          child: Opacity(
            opacity: blockedReason != null ? 0.55 : 1.0,
            child: AppPrimaryButton(
              buttonText: continueLabel,
              trailingIcon: Icons.arrow_forward_rounded,
              isDisabled: false,
              onPressed: () {
                if (blockedReason != null) {
                  AppFeedback.show(
                    context,
                    message: blockedReason!,
                    type: AppFeedbackType.warning,
                  );
                  return;
                }
                onContinue();
              },
            ),
          ),
        ),
      ],
    );
  }
}
