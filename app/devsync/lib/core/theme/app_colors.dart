import 'package:flutter/material.dart';

/// Usage:
///   final c = context.colors;   // or Theme.of(context).extension<AppColors>()!
///   Container(color: c.surface);
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryPressed,
    required this.darkBlueAccent,
    required this.onPrimary,
    required this.backgroundPrimary,
    required this.surface,
    required this.secondarySurface,
    required this.subtleBlueSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color primary;
  final Color primaryPressed;
  final Color darkBlueAccent;
  final Color onPrimary;
  final Color backgroundPrimary;
  final Color surface;
  final Color secondarySurface;
  final Color subtleBlueSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color error;

  // ───────────────────────── Light Mode ─────────────────────────
  static const AppColors light = AppColors(
    primary: Color(0xFF315BDB),
    primaryPressed: Color(0xFF2548B8),
    darkBlueAccent: Color(0xFF173B9A),
    onPrimary: Color(0xFFFFFFFF),
    backgroundPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F7FC),
    secondarySurface: Color(0xFFF5F7FC),
    subtleBlueSurface: Color(0xFFEEF3FF),
    textPrimary: Color(0xFF17233D),
    textSecondary: Color(0xFF65718A),
    border: Color(0xFFDDE4F2),
    success: Color(0xFF16845B),
    warning: Color(0xFFA86512),
    error: Color(0xFFC43D4B),
  );

  // ───────────────────────── Dark Mode ──────────────────────────
  static const AppColors dark = AppColors(
    primary: Color(0xFF6F91FF),
    primaryPressed: Color(0xFF8AA5FF),
    darkBlueAccent: Color(0xFF315BDB),
    onPrimary: Color(0xFF101522),
    backgroundPrimary: Color(0xFF101522),
    surface: Color(0xFF171E2E),
    secondarySurface: Color(0xFF202A3D),
    subtleBlueSurface: Color(0xFF1D2B49),
    textPrimary: Color(0xFFF5F7FF),
    textSecondary: Color(0xFFA9B4C9),
    border: Color(0xFF303B51),
    success: Color(0xFF4CCB91),
    warning: Color(0xFFF0B85A),
    error: Color(0xFFFF7581),
  );

  /// Ambient micro-tint shadow for Level 2 overlays: rgba(23, 35, 61, 0.04).
  static const Color ambientShadow = Color(0x0A17233D);

  /// Subtle background for status badges, derived from a status color.
  Color subtle(Color color) => color.withValues(alpha: 0.12);

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryPressed,
    Color? darkBlueAccent,
    Color? onPrimary,
    Color? backgroundPrimary,
    Color? surface,
    Color? secondarySurface,
    Color? subtleBlueSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      darkBlueAccent: darkBlueAccent ?? this.darkBlueAccent,
      onPrimary: onPrimary ?? this.onPrimary,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      surface: surface ?? this.surface,
      secondarySurface: secondarySurface ?? this.secondarySurface,
      subtleBlueSurface: subtleBlueSurface ?? this.subtleBlueSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      darkBlueAccent: Color.lerp(darkBlueAccent, other.darkBlueAccent, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      backgroundPrimary:
          Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      secondarySurface:
          Color.lerp(secondarySurface, other.secondarySurface, t)!,
      subtleBlueSurface:
          Color.lerp(subtleBlueSurface, other.subtleBlueSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}