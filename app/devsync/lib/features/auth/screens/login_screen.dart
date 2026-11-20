import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/utils/validators.dart';
import 'package:devsync/features/auth/business_logic/auth_cubit.dart';
import 'package:devsync/features/auth/business_logic/auth_state.dart';
import 'package:devsync/features/auth/utils/auth_navigation.dart';
import 'package:devsync/features/auth/widgets/auth_back_button.dart';
import 'package:devsync/features/auth/widgets/auth_footer_link.dart';
import 'package:devsync/features/auth/widgets/auth_header.dart';
import 'package:devsync/features/auth/widgets/google_button.dart';
import 'package:devsync/features/auth/widgets/or_divider.dart';
import 'package:devsync/features/auth/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'create_account_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) showAuthMessage(context, state.message);
        if (state is AuthSuccess) onAuthenticated(context);
      },
      builder: (context, state) {
        final loading = state is AuthLoading;
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthBackButton(),
                    const SizedBox(height: 8),
                    const AuthHeader(
                      title: 'Welcome back',
                      subtitle: 'Sign in to continue to DevSync.',
                    ),
                    const SizedBox(height: 32),
                    AppInputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'alex@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !loading,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      // Login only needs "not empty" (not the strength rule).
                      validator: (v) =>
                          v.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppTextButton(
                        buttonText: 'Forgot Password?',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        buttonText: loading ? 'Please wait...' : 'Log In',
                        isDisabled: loading,
                        onPressed: _onLogin,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const OrDivider(),
                    const SizedBox(height: 16),
                    GoogleButton(
                      onPressed: () =>
                          context.read<AuthCubit>().signInWithGoogle(),
                    ),
                    const SizedBox(height: 28),
                    AuthFooterLink(
                      text: "Don't have an account?",
                      actionLabel: 'Sign Up',
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen(),
                        ),
                      ),
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
