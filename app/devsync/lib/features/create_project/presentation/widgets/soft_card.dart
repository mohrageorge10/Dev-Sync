import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Rounded container with a thin border (base of every card), using AppColors.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}