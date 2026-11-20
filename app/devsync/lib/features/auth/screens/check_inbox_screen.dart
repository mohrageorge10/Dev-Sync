import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/auth/business_logic/auth_cubit.dart';
import 'package:devsync/features/auth/business_logic/auth_state.dart';
import 'package:devsync/features/auth/utils/auth_navigation.dart';
import 'package:devsync/features/auth/widgets/auth_app_bar.dart';
import 'package:devsync/features/auth/widgets/info_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final c = context.colors;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) showAuthMessage(context, state.message);
        if (state is PasswordResetSent) {
          showAuthMessage(context, 'A new reset link was sent to $email');
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
                  Text(
                    'Check your inbox',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: c.textSecondary,
                      ),
                      children: [
                        const TextSpan(
                          text: "We've sent a password reset link to ",
                        ),
                        TextSpan(
                          text: email,
                          style: TextStyle(color: c.textPrimary),
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
                      onPressed: () => context
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
                      // Pops this screen + Forgot Password, landing on Log In.
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
