import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  final Color? trailingColor;
  final IconData? icon;
  const SectionLabel(this.text, {super.key, this.trailing, this.trailingColor, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Row(children: [
        if (icon != null) Padding(padding: const EdgeInsets.only(right: 8), child: Icon(icon, size: 17, color: c.primary)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
        if (trailing != null) Text(trailing!, style: TextStyle(fontSize: 12, color: trailingColor ?? c.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
