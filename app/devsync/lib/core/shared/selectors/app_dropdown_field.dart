import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.prefixIcon,
    this.validator,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final String? Function(T? value)? validator;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          validator: validator,
          onChanged: onChanged,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: c.backgroundPrimary,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(fontSize: 16, color: c.textPrimary),
          hint: hint == null ? null : Text(hint!),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))),
          ],
          decoration: InputDecoration(
            hintStyle: TextStyle(color: c.textSecondary),
            filled: true,
            fillColor: c.surface,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: c.primary),
            border: _border(c.border, 1),
            enabledBorder: _border(c.border, 1),
            focusedBorder: _border(c.primary, 1.5),
            errorBorder: _border(c.error, 1.5),
            focusedErrorBorder: _border(c.error, 1.5),
            errorStyle: TextStyle(fontSize: 12, color: c.error),
          ),
        ),
      ],
    );
  }
}