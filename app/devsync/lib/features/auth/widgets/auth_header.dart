import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.centered = false,
  });

  final String title;
  final String subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: align,
          style: TextStyle(fontSize: 14, height: 1.4, color: c.textSecondary),
        ),
      ],
    );
  }
}
