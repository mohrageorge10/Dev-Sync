import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Labeled filter section wrapper.
class FilterSection extends StatelessWidget {
  const FilterSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailingText,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: c.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: AppStyles.body13Bold(context)),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: AppStyles.body11Secondary(context),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}