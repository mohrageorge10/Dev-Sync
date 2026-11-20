import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TermsCheckbox extends StatelessWidget {
  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final link = TextStyle(fontWeight: FontWeight.w700, color: c.darkBlueAccent);

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            checkColor: c.onPrimary,
            side: BorderSide(color: c.border),
            fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? c.primary
                  : c.surface,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (v) => onChanged(v ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 12, color: c.textPrimary),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(text: 'Terms of Service', style: link),
                const TextSpan(text: ' and '),
                TextSpan(text: 'Privacy Policy', style: link),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
