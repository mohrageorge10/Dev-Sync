import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Theme-aware app brand logo widget.
class DevSyncLogo extends StatelessWidget {
  const DevSyncLogo({
    super.key,
    this.size = 44,
    this.borderRadius,
  });

  final double size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = isDark ? AppImages.darkLogo : AppImages.lightLogo;
    final radius = borderRadius ?? size * 0.25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(
            Icons.hub_rounded,
            color: c.onPrimary,
            size: size * 0.56,
          ),
        ),
      ),
    );
  }
}
