import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Section heading label used inside project cards and forms.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: AppStyles.body14Bold(context)),
    );
  }
}
