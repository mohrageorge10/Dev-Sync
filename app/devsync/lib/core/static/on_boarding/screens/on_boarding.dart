import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/static/on_boarding/widgets/onboarding_bottom_actions.dart';
import 'package:devsync/core/static/on_boarding/widgets/onboarding_page_indicator.dart';
import 'package:devsync/core/static/on_boarding/widgets/onboarding_slide_data.dart';
import 'package:devsync/core/static/on_boarding/widgets/onboarding_slide_view.dart';
import 'package:devsync/core/static/on_boarding/widgets/onboarding_top_bar.dart';
import 'package:devsync/core/static/splash/Splash.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Multi-step onboarding flow introducing core DevSync features.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  bool get _isLastPage => _currentIndex == onboardingSlides.length - 1;

  Future<void> _completeOnboarding(String targetRoute) async {
    await CacheHelper.saveData(key: Splash.seenOnboardingKey, value: true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (_) => false);
  }

  void _onPrimaryAction() {
    if (!_isLastPage) {
      _pageController.nextPage(
        duration: AppAnimations.medium,
        curve: AppAnimations.easeOut,
      );
      return;
    }
    _completeOnboarding(AppRoutes.authEntry);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentIndex > 0) {
          _pageController.previousPage(
            duration: AppAnimations.medium,
            curve: AppAnimations.easeOut,
          );
        }
      },
      child: Scaffold(
        backgroundColor: c.backgroundPrimary,
        appBar: OnboardingTopBar(
          showSkip: !_isLastPage,
          onSkip: () => _completeOnboarding(AppRoutes.authEntry),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: onboardingSlides.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (_, index) =>
                        OnboardingSlideView(slide: onboardingSlides[index]),
                  ),
                ),
                const SizedBox(height: 16),
                OnboardingPageIndicator(
                  count: onboardingSlides.length,
                  currentIndex: _currentIndex,
                ),
                const SizedBox(height: 28),
                OnboardingBottomActions(
                  isLastPage: _isLastPage,
                  onPrimaryPressed: _onPrimaryAction,
                  onGuestPressed: () =>
                      _completeOnboarding(AppRoutes.discoverGuest),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
