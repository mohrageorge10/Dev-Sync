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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffF1F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xffC4C5D7)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              if (leadingIcon != null)
                Icon(leadingIcon, color: Color(0xff0F1C31)),
              Text(buttonText, style: AppStyles.primary_16_500),
              if (trailingIcon != null)
                Icon(trailingIcon, color: Color(0xff0F1C31)),
            ],
          ),
        ),
      ),
    );
  }
}
