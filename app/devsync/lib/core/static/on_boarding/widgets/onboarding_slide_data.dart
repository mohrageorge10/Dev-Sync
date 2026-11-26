import 'package:devsync/core/constants/app_images.dart';

// Immutable data model for a single onboarding slide.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  final String imagePath;
  final String title;
  final String subtitle;
}

// Default DevSync onboarding slides.
const List<OnboardingSlideData> onboardingSlides = [
  OnboardingSlideData(
    imagePath: AppImages.onboarding1,
    title: 'Find projects that truly\nmatch your skills',
    subtitle:
        'Discover projects that fit your skills, interests, and goals.',
  ),
  OnboardingSlideData(
    imagePath: AppImages.onboarding2,
    title: 'Know why a project\nfits you',
    subtitle:
        'Understand your strengths, discover skill gaps, and find opportunities to grow.',
  ),
  OnboardingSlideData(
    imagePath: AppImages.onboarding3,
    title: 'Build your team\nand ship',
    subtitle:
        'Create projects, find collaborators, chat, and manage tasks in one place.',
  ),
];
