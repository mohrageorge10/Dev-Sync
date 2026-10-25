import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppInputField extends StatefulWidget {
  const AppInputField({
    super.key,
    required this.controller,
    this.label,
    this.trailingLabel,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
  });

  final TextEditingController controller;

  /// Label shown above the field (e.g. "Repository URL").
  final String? label;

  /// Small text on the right of the label (e.g. "Optional").
  final String? trailingLabel;

  final String? hint;
  final IconData? prefixIcon;

  /// Return an error message, or null when the value is valid.
  final String? Function(String value)? validator;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
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

    return FormField<String>(
      initialValue: widget.controller.text,
      enabled: widget.enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => widget.validator?.call(widget.controller.text),
      builder: (state) {
        final hasError = state.hasError;
        final focused = _focusNode.hasFocus;
        final hasText = widget.controller.text.isNotEmpty;

        // Accent color: red on error, blue on focus, otherwise neutral.
        final Color? accent = hasError
            ? c.error
            : focused
                ? c.primary
                : null;

        Widget? suffix;
        if (hasError) {
          suffix = Icon(Icons.error_outline_rounded, color: c.error, size: 24);
        } else if (focused && hasText) {
          suffix =
              Icon(Icons.check_circle_outline_rounded, color: c.primary, size: 24);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null || widget.trailingLabel != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.label != null)
                    Text(
                      widget.label!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.14,
                        color: accent ?? c.textPrimary,
                      ),
                    ),
                  if (widget.trailingLabel != null)
                    Text(
                      widget.trailingLabel!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.24,
                        color: accent ?? c.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: accent ?? c.primary,
              style: TextStyle(
                fontSize: 16,
                height: 24 / 16,
                color: hasError ? c.error : c.textPrimary,
              ),
              onChanged: (value) {
                state.didChange(value);
                widget.onChanged?.call(value);
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  color: c.textSecondary,
                ),
                filled: true,
                // Focused / error: white background, otherwise surface.
                fillColor:
                    (focused || hasError) ? c.backgroundPrimary : c.surface,
                constraints: const BoxConstraints(minHeight: 48),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : Icon(widget.prefixIcon,
                        size: 24, color: accent ?? c.textSecondary),
                suffixIcon: suffix,
                border: _border(c.border, 1),
                enabledBorder: _border(c.border, 1),
                disabledBorder: _border(c.border, 1),
                focusedBorder: _border(c.primary, 1.5),
                errorBorder: _border(c.error, 1.5),
                focusedErrorBorder: _border(c.error, 1.5),
                // Error text sits 4px below the field.
                errorText: state.errorText,
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
      },
    );
  }
}