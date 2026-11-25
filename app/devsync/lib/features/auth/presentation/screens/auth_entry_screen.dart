import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_navigation.dart';
import 'package:flutter/material.dart';

// Entry screen offering Create Account, Log In, or Guest Mode.
class AuthEntryScreen extends StatelessWidget {
  const AuthEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const AppFadeSlide(
                child: DevSyncLogo(size: 132),
              ),
              const SizedBox(height: 24),
              AppFadeSlide(
                delay: const Duration(milliseconds: 80),
                child: Text('DevSync', style: AppStyles.h30(context)),
              ),
              const SizedBox(height: 8),
              AppFadeSlide(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  'Connect. Collaborate. Build.',
                  style: AppStyles.gray_16_500(context),
                ),
              ),
              const SizedBox(height: 14),
              AppFadeSlide(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'The AI-powered platform for developers to discover matched open-source projects and build together.',
                    textAlign: TextAlign.center,
                    style: AppStyles.body14Secondary(context),
                  ),
                ),
              ),
              const Spacer(flex: 4),
              AppFadeSlide(
                delay: const Duration(milliseconds: 260),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        buttonText: 'Create Account',
                        trailingIcon: Icons.arrow_forward,
                        isDisabled: false,
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.createAccount,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AppSecondaryButton(
                        buttonText: 'Log In',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextButton(
                      buttonText: 'Continue as Guest',
                      onPressed: () => continueAsGuest(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
