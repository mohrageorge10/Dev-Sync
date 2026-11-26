import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Rounded bordered container card for profile sections.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;

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
