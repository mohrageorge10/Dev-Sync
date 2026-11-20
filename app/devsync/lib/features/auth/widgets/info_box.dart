import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.icon,
    required this.text,
    this.title,
  });

  final IconData icon;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
