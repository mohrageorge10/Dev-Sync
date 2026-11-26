import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Horizontal divider with centered label.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.text = 'or'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Expanded(child: Divider(color: c.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: AppStyles.body12Secondary(context)),
        ),
        Expanded(child: Divider(color: c.border)),
      ],
    );
  }
}
