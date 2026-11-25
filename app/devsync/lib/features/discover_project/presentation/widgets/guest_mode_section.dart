import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Guest mode status indicator.
class GuestModeSection extends StatelessWidget {
  const GuestModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c.success, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'GUEST MODE EXPLORER',
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body11SemiBold(context, color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}