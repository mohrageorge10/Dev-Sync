import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Tinted icon badge used in auth headers and sheets.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.size = 64,
    this.circular = false,
  });

  final IconData icon;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.subtle(c.primary),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, size: size * 0.45, color: c.primary),
    );
  }
}
