import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(14), this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.backgroundPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? c.border),
      ),
      child: child,
    );
  }
}
