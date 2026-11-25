import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/animations/app_scale_tap.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:flutter/material.dart';

// Bottom CTA section for onboarding (Next / Get Started + Continue as Guest).
class OnboardingBottomActions extends StatelessWidget {
  const OnboardingBottomActions({
    super.key,
    required this.isLastPage,
    required this.onPrimaryPressed,
    required this.onGuestPressed,
  });

  final bool isLastPage;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onGuestPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppScaleTap(
          onTap: onPrimaryPressed,
          child: AppPrimaryButton(
            isDisabled: false,
            onPressed: onPrimaryPressed,
            buttonText: isLastPage ? 'Get Started' : 'Next',
            trailingIcon: isLastPage ? null : Icons.arrow_forward_rounded,
          ),
        ),
        AnimatedSize(
          duration: AppAnimations.fast,
          curve: AppAnimations.easeOut,
          child: isLastPage
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: AppTextButton(
                    onPressed: onGuestPressed,
                    buttonText: 'Continue as Guest',
                  ),
                )
              : const SizedBox(height: 8),
        ),
      ],
    );
  }
}
