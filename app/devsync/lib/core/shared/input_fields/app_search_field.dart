import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Search input field for discover and filter screens.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  final String hintText;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final readOnly = onTap != null && onChanged == null && controller == null;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: AppStyles.body13Bold(context),
      cursorColor: c.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.body12Secondary(context),
        filled: true,
        fillColor: c.surface,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: prefixIcon ?? Icon(Icons.search, color: c.textSecondary),
        border: _border(c.border),
        enabledBorder: _border(c.border),
        focusedBorder: _border(c.primary, 1.5),
      ),
    );
  }
}
