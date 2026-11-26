import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Horizontal progress bar for multi-step profile setup.
class ProfileStepProgress extends StatelessWidget {
  const ProfileStepProgress(this.percent, {super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$percent% completed', style: AppStyles.body11Secondary(context)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 5,
            backgroundColor: c.border,
            color: c.primary,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
