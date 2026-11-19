import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Centralized application text styles.
class AppStyles {
  AppStyles._();

  // Shared button styles.
  static TextStyle white_14_500(BuildContext context) => TextStyle(
    color: context.colors.onPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle primary_16_500(BuildContext context) => TextStyle(
    color: context.colors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle gray_16_500(BuildContext context) => TextStyle(
    color: context.colors.textSecondary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle lightPrimary_16_500(BuildContext context) => TextStyle(
    color: context.colors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  // Headings.
  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: context.colors.textPrimary,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: context.colors.textPrimary,
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: context.colors.textPrimary,
  );

  // Titles & section headers.
  static TextStyle title16Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle title15Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle label14SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  // Body styles (15 - 11px).
  static TextStyle body15(BuildContext context, {bool active = true}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: active
            ? context.colors.textPrimary
            : context.colors.textSecondary,
      );

  static TextStyle body13Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body12Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body12SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body12Primary(BuildContext context) =>
      TextStyle(fontSize: 12, color: context.colors.textPrimary);

  static TextStyle body12Secondary(BuildContext context) =>
      TextStyle(fontSize: 12, color: context.colors.textSecondary);

  static TextStyle body11Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body11SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body11Medium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color ?? context.colors.textSecondary,
      );

  static TextStyle body11Primary(BuildContext context) =>
      TextStyle(fontSize: 11, color: context.colors.textPrimary);

  static TextStyle body11Secondary(BuildContext context) =>
      TextStyle(fontSize: 11, color: context.colors.textSecondary);

  // Captions & overlines (10 - 9px).
  static TextStyle caption10Bold(
    BuildContext context, {
    Color? color,
    double? letterSpacing,
  }) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    color: color ?? context.colors.textPrimary,
  );

  static TextStyle caption10Secondary(BuildContext context, {Color? color}) =>
      TextStyle(fontSize: 10, color: color ?? context.colors.textSecondary);

  static TextStyle overline9Bold(
    BuildContext context, {
    Color? color,
    double letterSpacing = 0.6,
  }) => TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    color: color ?? context.colors.primary,
  );

  static TextStyle overline9SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.primary,
      );

  static TextStyle overline9Secondary(
    BuildContext context, {
    double? letterSpacing,
  }) => TextStyle(
    fontSize: 9,
    letterSpacing: letterSpacing,
    color: context.colors.textSecondary,
  );

  // Avatar initials style.
  static TextStyle avatarInitials(double radius, Color color) => TextStyle(
    fontSize: radius * 0.6,
    fontWeight: FontWeight.w700,
    color: color,
  );
}
