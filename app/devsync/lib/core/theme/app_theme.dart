
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.backgroundPrimary,
        extensions: const [AppColors.light],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.backgroundPrimary,
        extensions: const [AppColors.dark],
      );
}