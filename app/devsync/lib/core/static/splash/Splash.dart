import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Entry splash screen that routes users based on onboarding and auth state.
class Splash extends StatefulWidget {
  const Splash({super.key});

  static const String seenOnboardingKey = 'seenOnboarding';

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final seenOnboarding =
        CacheHelper.getData<bool>(key: Splash.seenOnboardingKey) ?? false;
    final isSignedIn = ServiceLocator.get<FirebaseAuthService>().isSignedIn;

    if (!mounted) return;

    final targetRoute = !seenOnboarding
        ? AppRoutes.onBoarding
        : isSignedIn
        ? AppRoutes.main
        : AppRoutes.authEntry;

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.84, end: 1.0),
                duration: AppAnimations.medium,
                curve: AppAnimations.spring,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: SizedBox(
                  width: 152,
                  height: 152,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 152,
                        height: 152,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: c.primary,
                          backgroundColor: c.primary.withValues(alpha: 0.14),
                        ),
                      ),
                      Container(
                        width: 138,
                        height: 138,
                        decoration: BoxDecoration(
                          color: c.subtleBlueSurface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: c.primary.withValues(alpha: 0.08),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const DevSyncLogo(size: 98, borderRadius: 24),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AppFadeSlide(
                delay: const Duration(milliseconds: 140),
                child: Text('DevSync', style: AppStyles.h30(context)),
              ),
              const SizedBox(height: 6),
              AppFadeSlide(
                delay: const Duration(milliseconds: 240),
                child: Text(
                  'Connect. Collaborate. Build.',
                  style: AppStyles.body14Secondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
