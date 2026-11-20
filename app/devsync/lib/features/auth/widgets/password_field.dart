import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Password field with a show/hide toggle.
/// Self-contained on purpose: it mirrors the look of the team's
/// AppInputField (same theme colors / radius) without modifying it.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon = Icons.lock_outline,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String? Function(String value)? validator;
  final TextInputAction? textInputAction;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final _focusNode = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final focused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          cursorColor: c.primary,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) => widget.validator?.call(v ?? ''),
          style: TextStyle(fontSize: 16, height: 24 / 16, color: c.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              color: c.textSecondary,
            ),
            filled: true,
            fillColor: focused ? c.backgroundPrimary : c.surface,
            constraints: const BoxConstraints(minHeight: 48),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: Icon(
              widget.prefixIcon,
              size: 24,
              color: focused ? c.primary : c.textSecondary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 22,
                color: c.textSecondary,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: _border(c.border, 1),
            enabledBorder: _border(c.border, 1),
            focusedBorder: _border(c.primary, 1.5),
            errorBorder: _border(c.error, 1.5),
            focusedErrorBorder: _border(c.error, 1.5),
            errorMaxLines: 2,
            errorStyle: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              color: c.error,
            ),
          ),
        ),
      ],
    );
  }
}
