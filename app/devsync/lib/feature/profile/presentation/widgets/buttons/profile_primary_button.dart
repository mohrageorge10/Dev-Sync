import 'package:flutter/material.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  const PrimaryButton(this.label, {super.key, this.onPressed, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      onPressed: onPressed ?? () {},
      buttonText: label,
      trailingIcon: icon,
      isDisabled: onPressed == null,
    );
  }
}
