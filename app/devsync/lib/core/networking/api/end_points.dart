import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoint {
  static const String baseUrl = '';
  static const String signIn = 'users/signin';
  static const String signUp = 'users/signup';
}

class ApiKey {
  /// Throws a clear error if the key is missing instead of silently
  /// sending a fake value. Read lazily, so `dotenv.load` must run first.
  static String get githubKey => _requireEnv('GITHUB_API_KEY');

  /// Web client ID (OAuth 2.0, type "Web application") from Google Cloud /
  /// Firebase console. Required by Google Sign-In v7 on Android.
  static String get googleServerClientId =>
      _requireEnv('GOOGLE_SERVER_CLIENT_ID');

  static String _requireEnv(String name) {
    final value = dotenv.env[name];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing "$name" in .env file.');
    }
    return value;
  }

  static const String token = 'token';
  static const String status = 'status';
  static const String errorMsg = 'ErrorMessage';
  static const String email = 'email';
  static const String password = 'password';
  static const String id = 'id';
  static const String msg = 'message';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String confirmPassword = 'confirmPassword';
  static const String location = 'location';
  static const String profilePic = 'profilePic';
}
