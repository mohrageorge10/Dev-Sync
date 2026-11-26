import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Section header with optional subtitle and trailing action text.
class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.title,
    required this.text,
    this.title2,
    this.onTap,
  });

  final String title;
  final String? title2;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppStyles.title16Bold(context)),
              if (title2 != null && title2!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(title2!, style: AppStyles.body12Secondary(context)),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Text(
              text,
              style: AppStyles.body12Bold(context, color: c.primary),
            ),
          ),
        ),
      ],
    );
  }
}
