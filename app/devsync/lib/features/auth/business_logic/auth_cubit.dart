import 'package:devsync/features/auth/business_logic/auth_state.dart';
import 'package:devsync/features/auth/data/models/user_model.dart';
import 'package:devsync/features/auth/data/repos/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepo _repo;

  static const _genericError = 'Something went wrong. Please try again.';

  /// Runs [action] with the shared loading / error handling.
  /// Ignores taps while another request is running (no double submit).
  Future<void> _run(Future<AuthState?> Function() action) async {
    if (state is AuthLoading) return;
    emit(const AuthLoading());
    try {
      final result = await action();
      if (isClosed) return;
      emit(result ?? const AuthInitial());
    } on AuthException catch (e) {
      if (!isClosed) emit(AuthError(e.message));
    } catch (_) {
      if (!isClosed) emit(const AuthError(_genericError));
    }
  }

  Future<void> login({required String email, required String password}) =>
      _run(() async {
        final UserModel user =
            await _repo.login(email: email.trim(), password: password);
        return AuthSuccess(user);
      });

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _run(() async {
        final UserModel user = await _repo.register(
          name: name.trim(),
          email: email.trim(),
          password: password,
        );
        return AuthSuccess(user);
      });

  Future<void> signInWithGoogle() => _run(() async {
        final user = await _repo.signInWithGoogle();
        // null = user cancelled the dialog -> back to initial, no error.
        return user == null ? null : AuthSuccess(user);
      });

  Future<void> sendPasswordResetEmail(String email) => _run(() async {
        final trimmed = email.trim();
        await _repo.sendPasswordResetEmail(trimmed);
        return PasswordResetSent(trimmed);
      });

  Future<void> logout() => _run(() async {
        await _repo.logout();
        return const AuthLoggedOut();
      });
}
