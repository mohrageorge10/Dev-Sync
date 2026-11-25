import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Animated pill/dot page indicator for the onboarding flow.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 26 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? c.primary : c.border,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
