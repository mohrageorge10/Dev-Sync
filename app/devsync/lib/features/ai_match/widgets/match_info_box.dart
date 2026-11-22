import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

/// Soft blue box with an icon and a short text (explanations, tips, notes).
class MatchInfoBox extends StatelessWidget {
  const MatchInfoBox({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: c.primary),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(text, style: AppStyles.body12Primary(context))),
        ],
      ),
    );
  }
}
