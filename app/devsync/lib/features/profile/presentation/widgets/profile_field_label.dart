import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Form field label with optional right-aligned hint text.
class ProfileFieldLabel extends StatelessWidget {
  const ProfileFieldLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppStyles.body12Bold(context))),
          if (trailing != null)
            Text(trailing!, style: AppStyles.caption10Secondary(context)),
        ],
      ),
    );
  }
}
