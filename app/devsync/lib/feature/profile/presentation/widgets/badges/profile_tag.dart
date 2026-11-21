import 'package:flutter/material.dart';
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color? fg;
  final Color? bg;
  const Tag(this.label, {super.key, this.fg, this.bg});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBadge(
      label: label,
      color: fg ?? c.primary,
      backgroundColor: bg ?? c.subtleBlueSurface,
    );
  }
}
