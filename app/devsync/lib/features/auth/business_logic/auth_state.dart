import 'package:devsync/features/auth/data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Password-reset email was sent to [email].
class PasswordResetSent extends AuthState {
  final String email;
  const PasswordResetSent(this.email);
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
