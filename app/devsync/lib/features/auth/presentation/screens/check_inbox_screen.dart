import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_state.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_navigation.dart';
import 'package:devsync/features/auth/presentation/widgets/info_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Confirmation screen shown after sending a password reset link.
class CheckInboxScreen extends StatelessWidget {
  const CheckInboxScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<AuthCubit>(),
      child: _CheckInboxView(email: email),
    );
  }
}

class _CheckInboxView extends StatelessWidget {
  const _CheckInboxView({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showAuthMessage(context, state.message, type: AppFeedbackType.error);
        }
        if (state is PasswordResetSent) {
          showAuthMessage(
            context,
            'A new reset link was sent to $email',
            type: AppFeedbackType.success,
          );
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          appBar: const AuthAppBar(title: 'Forgot Password'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/check_inbox_illustration.png',
                    width: 224,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  Text('Check your inbox', style: AppStyles.h26(context)),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      style: AppStyles.body14Secondary(context),
                      children: [
                        const TextSpan(
                          text: "We've sent a password reset link to ",
                        ),
                        TextSpan(
                          text: email,
                          style: AppStyles.body14Primary(context),
                        ),
                        const TextSpan(
                          text:
                              '. Follow the link in the email to set a new password.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const InfoBox(
                    icon: Icons.info_outline,
                    text:
                        "Didn't receive the email? Check your spam folder or request a new reset link below.",
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: AppSecondaryButton(
                      buttonText: loading ? 'Sending...' : 'Resend Email',
                      leadingIcon: Icons.forward_to_inbox_outlined,
                      onPressed: loading
                          ? () {}
                          : () => context
                              .read<AuthCubit>()
                              .sendPasswordResetEmail(email),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      buttonText: 'Back to Log In',
                      trailingIcon: Icons.arrow_forward,
                      isDisabled: false,
                      onPressed: () {
                        var popped = 0;
                        Navigator.popUntil(context, (_) => popped++ >= 2);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
