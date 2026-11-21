import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

InputDecoration fieldDeco({
  BuildContext? context,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? hintText,
  TextStyle? hintStyle,
  String? counterText,
  bool filled = true,
  EdgeInsetsGeometry? contentPadding,
}) =>
    InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: hintStyle,
      counterText: counterText,
      filled: filled,
      fillColor: context != null ? context.colors.surface : AppColors.light.surface,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
