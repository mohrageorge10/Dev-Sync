import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class CompactButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool filled;
  final Color? color;
  const CompactButton(this.label, {super.key, required this.onPressed, this.icon, this.filled = false, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: filled ? c : c.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) Padding(padding: const EdgeInsets.only(right: 4), child: Icon(icon, size: 13, color: filled ? Colors.white : c)),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: filled ? Colors.white : c)),
        ]),
      ),
    );
  }
}
