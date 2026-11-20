import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/utils/validators.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_state.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_header.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_navigation.dart';
import 'package:devsync/features/auth/presentation/widgets/google_button.dart';
import 'package:devsync/features/auth/presentation/widgets/or_divider.dart';
import 'package:devsync/features/auth/presentation/widgets/password_field.dart';
import 'package:devsync/features/auth/presentation/widgets/terms_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Registration screen with form validation and Google sign-up.
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<AuthCubit>(),
      child: const _CreateAccountView(),
    );
  }
}

class _CreateAccountView extends StatefulWidget {
  const _CreateAccountView();

  @override
  State<_CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<_CreateAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      showAuthMessage(
        context,
        'Please agree to the Terms of Service and Privacy Policy.',
        type: AppFeedbackType.warning,
      );
      return;
    }
    context.read<AuthCubit>().register(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showAuthMessage(context, state.message, type: AppFeedbackType.error);
        }
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
                      title: 'Create your account',
                      subtitle:
                          'Join developers building meaningful projects together.',
                    ),
                    const SizedBox(height: 28),
                    AppInputField(
                      controller: _nameCtrl,
                      label: 'Full name',
                      hint: 'e.g. Alex Morgan',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      enabled: !loading,
                      validator: AppValidators.validateName,
                    ),
                    const SizedBox(height: 16),
                    AppInputField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'alex@example.com',
                      prefixIcon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !loading,
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: 'Create a strong password',
                      textInputAction: TextInputAction.next,
                      enabled: !loading,
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(
                      controller: _confirmCtrl,
                      label: 'Confirm password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_clock_outlined,
                      textInputAction: TextInputAction.done,
                      enabled: !loading,
                      validator: (v) => AppValidators.validateConfirmPassword(
                        v,
                        _passCtrl.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TermsCheckbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        buttonText:
                            loading ? 'Please wait...' : 'Create Account',
                        isDisabled: loading,
                        onPressed: _onCreateAccount,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const OrDivider(text: 'or continue with google'),
                    const SizedBox(height: 16),
                    GoogleButton(
                      isDisabled: loading,
                      onPressed: () =>
                          context.read<AuthCubit>().signInWithGoogle(),
                    ),
                    const SizedBox(height: 12),
                    AuthFooterLink(
                      text: 'Already have an account?',
                      actionLabel: 'Log In',
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                    ),
                    const SizedBox(height: 16),
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
