import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Header bar for the filter bottom sheet.
class FilterHeader extends StatelessWidget {
  const FilterHeader({
    super.key,
    required this.activeCount,
    this.onClose,
  });

  final int activeCount;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Text('Filters', style: AppStyles.title17Bold(context)),
        if (activeCount > 0) ...[
          const SizedBox(width: 8),
          AppBadge(
            label: '$activeCount Active',
            color: c.primary,
            backgroundColor: c.subtleBlueSurface,
          ),
        ],
        const Spacer(),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close, size: 22, color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}