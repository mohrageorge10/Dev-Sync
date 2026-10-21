import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    required this.buttonText,
    this.isDisabled = true,
  });

  final VoidCallback onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String buttonText;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isDisabled ? Color(0xffDFE8FF) : Color(0xff0340C2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Icon(
                leadingIcon,
                color: isDisabled
                    ? Color.fromARGB(129, 67, 70, 84)
                    : Colors.white,
              ),
              Text(
                buttonText,
                style: isDisabled
                    ? AppStyles.gray_14_500
                    : AppStyles.white_14_500,
              ),
              Icon(
                trailingIcon,
                color: isDisabled
                    ? Color.fromARGB(129, 67, 70, 84)
                    : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
