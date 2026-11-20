import 'package:devsync/features/auth/data/model/user_model.dart';
import 'package:equatable/equatable.dart';

// Base state for authentication flows.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
