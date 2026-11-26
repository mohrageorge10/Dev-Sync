import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Initials avatar circle for applicants, owners, and developers.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.radius = 22});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final trimmed = name.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: c.subtleBlueSurface,
      child: Text(
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
        style: AppStyles.body14Bold(context, color: c.primary),
      ),
    );
  }
}
