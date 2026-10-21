import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    required this.buttonText,
  });

  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            if (leadingIcon != null)
              Icon(leadingIcon, color: Color(0xff0340C2)),
            Text(buttonText, style: AppStyles.lightPrimary_14_500),
            if (trailingIcon != null)
              Icon(trailingIcon, color: Color(0xff0340C2)),
          ],
        ),
      ),
    );
  }
}
