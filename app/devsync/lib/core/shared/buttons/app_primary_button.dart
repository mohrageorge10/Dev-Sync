import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.leadingIcon,
    this.trailingIcon,
    this.isDisabled = true,
  });

  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String buttonText;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = Text(
          buttonText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isDisabled
              ? AppStyles.gray_16_500(context)
              : AppStyles.white_14_500(context),
        );
        return GestureDetector(
          onTap: isDisabled ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: isDisabled ? c.subtleBlueSurface : c.primary,
              borderRadius: BorderRadius.circular(12),
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
                    Icon(
                      leadingIcon,
                      size: 18,
                      color: isDisabled ? c.textSecondary : c.onPrimary,
                    ),
                  if (constraints.hasBoundedWidth)
                    Flexible(child: label)
                  else
                    label,
                  if (trailingIcon != null)
                    Icon(
                      trailingIcon,
                      size: 18,
                      color: isDisabled ? c.textSecondary : c.onPrimary,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
