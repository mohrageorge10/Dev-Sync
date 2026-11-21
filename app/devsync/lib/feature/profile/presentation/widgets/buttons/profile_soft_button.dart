import 'package:flutter/material.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';

class SoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const SoftButton(this.label, {super.key, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return AppSecondaryButton(
      onPressed: onPressed ?? () {},
      buttonText: label,
      leadingIcon: icon,
    );
  }
}
