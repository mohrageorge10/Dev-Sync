class AppConstants {
  AppConstants._();
  // ================= Validation Numbers =================
  static const int passwordMinLength = 8;
  static const int nameMinLength = 3;

  // ================= Caching Limits =================
  static const int githubCacheExpirationHours = 24; // 24 hour

  // ================= Regular Expressions =================
  static const String emailRegex = r'^[\w\-.]+@([\w\-]+\.)+[a-zA-Z]{2,}$';
  static const String passwordRegex =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$';
  static const String urlRegex =
      r'^(https?:\/\/)?([\w\-]+\.)+[A-Za-z]{2,}(\/.*)?$';

  // ================= Timers & Delays =================
  static const int splashDelay = 3;
  static const int apiTimeout = 30;

  // ================= SharedPreferences Keys  =================
  static const String prefsIsDarkTheme = 'is_dark_theme';
  static const String prefsSeenOnboarding = 'seenOnboarding';
  static const String prefsIsGuest = 'is_guest';

  // ================= App Flavors =================
  static const String flavorFree = 'free';
  static const String flavorPro = 'pro';
}
