import 'package:devsync/core/static/on_boarding/widgets/onboarding_slide_data.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Single onboarding page displaying the asset illustration, title, and subtitle.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Image.asset(
            slide.imagePath,
            height: 250,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppStyles.h28(context),
          ),
          const SizedBox(height: 14),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: AppStyles.body15Secondary(context),
          ),
        ],
      ),
    );
  }
}
