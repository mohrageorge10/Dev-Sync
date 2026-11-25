import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Global light and dark application themes synced with AppColors.
class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);
  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.primary,
      onSecondary: c.onPrimary,
      error: c.error,
      onError: c.onPrimary,
      surface: c.backgroundPrimary,
      onSurface: c.textPrimary,
      outline: c.border,
      surfaceContainerHighest: c.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.backgroundPrimary,
      datePickerTheme: _datePickerTheme(c),
      extensions: [c],
    );
  }

  // Unified calendar/date picker theme across the entire app.
  static DatePickerThemeData _datePickerTheme(AppColors c) {
    return DatePickerThemeData(
      backgroundColor: c.backgroundPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: c.border),
      ),
      headerBackgroundColor: c.subtleBlueSurface,
      headerForegroundColor: c.textPrimary,
      headerHelpStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: c.primary,
      ),
      headerHeadlineStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c.textPrimary,
      ),
      weekdayStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
      dayStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.onPrimary;
        if (states.contains(WidgetState.disabled)) {
          return c.textSecondary.withValues(alpha: 0.4);
        }
        return c.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.primary;
        return Colors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.onPrimary;
        return c.primary;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.primary;
        return c.subtleBlueSurface;
      }),
      todayBorder: BorderSide(color: c.primary, width: 1.2),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.onPrimary;
        return c.textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return c.primary;
        return Colors.transparent;
      }),
      dividerColor: c.border,
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: c.textSecondary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: c.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}
