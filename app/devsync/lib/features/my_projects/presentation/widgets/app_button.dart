import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Reusable full-width button (filled or outlined) for My Projects screens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                side: BorderSide(color: color ?? c.border),
                foregroundColor: color ?? c.textPrimary,
              ),
              child: Text(
                label,
                style: AppStyles.body14Bold(
                  context,
                  color: color ?? c.textPrimary,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? c.primary,
                foregroundColor: c.onPrimary,
                elevation: 0,
                shape: shape,
              ),
              child: Text(
                label,
                style: AppStyles.body14Bold(context, color: c.onPrimary),
              ),
            ),
    );
  }
}
