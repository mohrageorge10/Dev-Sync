import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
    this.inputFormatters,
    this.trailingLabelColor,
    this.suffixIcon,
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
  final ValueChanged<String>? onSubmitted;

  final TextCapitalization textCapitalization;

  /// Multi-line support (keep maxLines = 1 for single-line / obscured text).
  final int? minLines;
  final int? maxLines;

  /// e.g. LengthLimitingTextInputFormatter(80).
  final List<TextInputFormatter>? inputFormatters;

  /// Color of [trailingLabel] when the field has no error/focus accent
  /// (e.g. orange character counter near the limit).
  final Color? trailingLabelColor;

  final Widget? suffixIcon;

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

        Widget? suffix = widget.suffixIcon;
        if (suffix == null) {
          if (hasError) {
            suffix = Icon(Icons.error_outline_rounded, color: c.error, size: 24);
          } else if (focused && hasText) {
            suffix = Icon(
              Icons.check_circle_outline_rounded,
              color: c.primary,
              size: 24,
            );
          }
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
                      style: AppStyles.label14SemiBold(
                        context,
                        color: accent ?? c.textPrimary,
                      ),
                    ),
                  if (widget.trailingLabel != null)
                    Text(
                      widget.trailingLabel!,
                      style: AppStyles.body12Medium(
                        context,
                        color: accent ??
                            widget.trailingLabelColor ??
                            c.textSecondary,
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
              textCapitalization: widget.textCapitalization,
              minLines: widget.minLines,
              maxLines: widget.maxLines,
              inputFormatters: widget.inputFormatters,
              onSubmitted: widget.onSubmitted,
              cursorColor: accent ?? c.primary,
              style: AppStyles.inputText(context, hasError: hasError),
              onChanged: (value) {
                state.didChange(value);
                widget.onChanged?.call(value);
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppStyles.inputHint(context),
                filled: true,
                fillColor:
                    (focused || hasError) ? c.backgroundPrimary : c.surface,
                constraints: const BoxConstraints(minHeight: 48),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : Icon(
                        widget.prefixIcon,
                        size: 24,
                        color: accent ?? c.textSecondary,
                      ),
                suffixIcon: suffix,
                border: _border(c.border, 1),
                enabledBorder: _border(c.border, 1),
                disabledBorder: _border(c.border, 1),
                focusedBorder: _border(c.primary, 1.5),
                errorBorder: _border(c.error, 1.5),
                focusedErrorBorder: _border(c.error, 1.5),
                errorText: state.errorText,
                errorMaxLines: 2,
                errorStyle: AppStyles.body12Error(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
