import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/utils/validators.dart';
import 'package:devsync/features/auth/business_logic/auth_cubit.dart';
import 'package:devsync/features/auth/business_logic/auth_state.dart';
import 'package:devsync/features/auth/utils/auth_navigation.dart';
import 'package:devsync/features/auth/widgets/auth_app_bar.dart';
import 'package:devsync/features/auth/widgets/auth_footer_link.dart';
import 'package:devsync/features/auth/widgets/auth_header.dart';
import 'package:devsync/features/auth/widgets/icon_badge.dart';
import 'package:devsync/features/auth/widgets/info_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'check_inbox_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<AuthCubit>(),
      child: const _ForgotPasswordView(),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().sendPasswordResetEmail(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) showAuthMessage(context, state.message);
        if (state is PasswordResetSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckInboxScreen(email: state.email),
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          appBar: const AuthAppBar(title: 'Forgot Password'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const IconBadge(icon: Icons.lock_reset, size: 68),
                    const SizedBox(height: 20),
                    const AuthHeader(
                      centered: true,
                      title: 'Reset your password',
                      subtitle:
                          "Enter the email associated with your DevSync account, and we'll send you a secure link to reset your password.",
                    ),
                    const SizedBox(height: 32),
                    AppInputField(
                      controller: _emailCtrl,
                      label: 'Email address',
                      hint: 'alex@example.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      enabled: !loading,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: c.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Make sure you have access to this email inbox.',
                          style:
                              TextStyle(fontSize: 12, color: c.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        buttonText:
                            loading ? 'Sending...' : 'Send Reset Link',
                        trailingIcon: loading ? null : Icons.arrow_forward,
                        isDisabled: loading,
                        onPressed: _onSendResetLink,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const InfoBox(
                      icon: Icons.shield_outlined,
                      title: 'End-to-End Link Protection',
                      text:
                          'Reset tokens expire automatically after 15 minutes for project workspace security.',
                    ),
                    const SizedBox(height: 32),
                    AuthFooterLink(
                      text: 'Remember password?',
                      actionLabel: 'Log In',
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
