import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';

Widget screenTitle(String t, String sub, [BuildContext? context]) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: AppStyles.primary_28_700),
      const SizedBox(height: 4),
      Text(sub, style: TextStyle(fontSize: 12, color: context != null ? context.colors.textSecondary : AppColors.light.textSecondary, height: 1.4)),
      const SizedBox(height: 16),
    ]);
