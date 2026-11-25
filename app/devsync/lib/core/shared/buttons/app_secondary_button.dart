import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.leadingIcon,
    this.trailingIcon,
  });

  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = Text(
          buttonText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.primary_16_500(context),
        );
        return GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                mainAxisSize: constraints.hasBoundedWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  if (leadingIcon != null)
                    Icon(leadingIcon, size: 18, color: c.textPrimary),
                  if (constraints.hasBoundedWidth)
                    Flexible(child: label)
                  else
                    label,
                  if (trailingIcon != null)
                    Icon(trailingIcon, size: 18, color: c.textPrimary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
