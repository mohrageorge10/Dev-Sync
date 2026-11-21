import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const FieldLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 10, color: c.textSecondary)),
      ]),
    );
  }
}
