import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Summary card showing live matching count inside filters.
class MatchingOpportunitiesCard extends StatelessWidget {
  const MatchingOpportunitiesCard({
    super.key,
    required this.count,
    required this.summary,
  });

  final int count;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome, size: 20, color: c.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count matching opportunities',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 3),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.body12Secondary(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}