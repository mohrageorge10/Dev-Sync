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
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? c.subtleBlueSurface : c.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              if (leadingIcon != null)
                Icon(
                  leadingIcon,
                  color: isDisabled ? c.textSecondary : c.onPrimary,
                ),
              Text(
                buttonText,
                style: isDisabled
                    ? AppStyles.gray_16_500(context)
                    : AppStyles.white_14_500(context),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: isDisabled ? c.textSecondary : c.onPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
