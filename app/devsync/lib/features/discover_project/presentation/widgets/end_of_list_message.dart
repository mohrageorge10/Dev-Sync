import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Footer indicator shown at the end of the developer list.
class EndOfListMessage extends StatelessWidget {
  const EndOfListMessage({
    super.key,
    this.title = "You've reached the end of top matches",
    this.subtitle =
        'Adjust your skills filter to discover more\nengineers across specialized tracks.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.all_inclusive, color: c.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyles.body14Bold(context),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
        ],
      ),
    );
  }
}