import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Confirmation dialog before withdrawing a pending project application.
Future<bool> showCancelApplicationDialog(
  BuildContext context, {
  required String projectTitle,
}) async {
  final c = context.colors;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.backgroundPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Cancel application?',
        style: AppStyles.title17Bold(ctx),
      ),
      content: Text(
        'Your request to join "$projectTitle" will be withdrawn.',
        style: AppStyles.body14Secondary(ctx),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Keep', style: AppStyles.body14Secondary(ctx)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Cancel Request',
            style: AppStyles.body14Bold(ctx, color: c.error),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
