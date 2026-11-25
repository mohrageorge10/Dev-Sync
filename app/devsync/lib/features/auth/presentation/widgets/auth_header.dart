import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Title and subtitle header for auth screens.
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
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title, textAlign: align, style: AppStyles.h26(context)),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: align,
          style: AppStyles.body14Secondary(context),
        ),
      ],
    );
  }
}
