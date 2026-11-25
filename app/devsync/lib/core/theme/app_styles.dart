import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Centralized application text styles with a consistent typography scale.
class AppStyles {
  AppStyles._();

  // Shared button & action styles.
  static TextStyle white_14_500(BuildContext context) => TextStyle(
    color: context.colors.onPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle primary_16_500(BuildContext context) => TextStyle(
    color: context.colors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle gray_16_500(BuildContext context) => TextStyle(
    color: context.colors.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle lightPrimary_16_500(BuildContext context) => TextStyle(
    color: context.colors.primary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // Headings (28 -> 17px).
  static TextStyle h30(BuildContext context) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.4,
    color: context.colors.textPrimary,
  );

  static TextStyle h28(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: context.colors.textPrimary,
  );

  static TextStyle h26(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.3,
    color: context.colors.textPrimary,
  );

  static TextStyle h1(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -0.2,
    color: context.colors.textPrimary,
  );

  static TextStyle h2(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.15,
    color: context.colors.textPrimary,
  );

  static TextStyle h20(BuildContext context) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: context.colors.textPrimary,
  );

  static TextStyle h3(BuildContext context) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: context.colors.textPrimary,
  );

  // Titles & section headers (17 -> 15px).
  static TextStyle title17Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle title17SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle title16Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle title16SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle title15Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  // Body & labels (15 -> 11px).
  static TextStyle body15(BuildContext context, {bool active = true}) =>
      TextStyle(
        fontSize: 15,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        height: 1.4,
        color: active
            ? context.colors.textPrimary
            : context.colors.textSecondary,
      );

  static TextStyle body15Secondary(BuildContext context) => TextStyle(
    fontSize: 15,
    height: 1.45,
    color: context.colors.textSecondary,
  );

  static TextStyle label14SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body14Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body14Primary(BuildContext context) =>
      TextStyle(fontSize: 14, height: 1.45, color: context.colors.textPrimary);

  static TextStyle body14Secondary(BuildContext context) => TextStyle(
    fontSize: 14,
    height: 1.45,
    color: context.colors.textSecondary,
  );

  static TextStyle body13Bold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body13SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.textPrimary,
      );

  static TextStyle body13Primary(BuildContext context) =>
      TextStyle(fontSize: 13, height: 1.35, color: context.colors.textPrimary);

  static TextStyle body13Secondary(BuildContext context) =>
      TextStyle(fontSize: 13, height: 1.4, color: context.colors.textSecondary);

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

  static TextStyle body12Medium(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? context.colors.textSecondary,
      );

  static TextStyle body12Primary(BuildContext context) =>
      TextStyle(fontSize: 12, color: context.colors.textPrimary);

  static TextStyle body12Secondary(BuildContext context) =>
      TextStyle(fontSize: 12, color: context.colors.textSecondary);

  static TextStyle body12Error(BuildContext context) =>
      TextStyle(fontSize: 12, color: context.colors.error);

  static TextStyle inputText(BuildContext context, {bool hasError = false}) =>
      TextStyle(
        fontSize: 15,
        height: 1.45,
        color: hasError ? context.colors.error : context.colors.textPrimary,
      );

  static TextStyle inputHint(BuildContext context) => TextStyle(
    fontSize: 15,
    height: 1.45,
    color: context.colors.textSecondary,
  );

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

  // Captions & overlines (10px).
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
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: letterSpacing,
    color: color ?? context.colors.primary,
  );

  static TextStyle overline9SemiBold(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color ?? context.colors.primary,
      );

  static TextStyle overline9Secondary(
    BuildContext context, {
    double? letterSpacing,
  }) => TextStyle(
    fontSize: 10,
    letterSpacing: letterSpacing,
    color: context.colors.textSecondary,
  );

  // Avatar initials style.
  static TextStyle avatarInitials(double radius, Color color) => TextStyle(
    fontSize: radius * 0.58,
    fontWeight: FontWeight.w700,
    color: color,
  );
}
