import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Match insight banner inside project and developer cards.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.singleLine = false});

  final String text;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.auto_awesome, size: 16, color: c.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: singleLine ? 1 : null,
              softWrap: !singleLine,
              overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.clip,
              style: AppStyles.body13Primary(context),
            ),
          ),
        ],
      ),
    );
  }
}