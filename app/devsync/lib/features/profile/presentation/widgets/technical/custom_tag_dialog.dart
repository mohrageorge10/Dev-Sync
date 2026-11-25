import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_decoration.dart';
import 'package:flutter/material.dart';

// Polished modal dialog for adding a custom skill or programming language.
Future<void> showCustomTagDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String hintText,
  required ValueChanged<String> onAdd,
}) async {
  final controller = TextEditingController();

  void submit(BuildContext dialogCtx) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    onAdd(value);
    Navigator.pop(dialogCtx);
  }

  await showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final c = dialogCtx.colors;
      return Dialog(
        backgroundColor: c.backgroundPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.subtleBlueSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add_rounded, size: 18, color: c.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(title, style: AppStyles.title17Bold(dialogCtx)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: AppStyles.body12Secondary(dialogCtx)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(dialogCtx),
                style: AppStyles.inputText(dialogCtx),
                decoration: profileFieldDecoration(
                  dialogCtx,
                  hintText: hintText,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ProfileSoftButton(
                      'Cancel',
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ProfilePrimaryButton(
                      'Add',
                      onPressed: () => submit(dialogCtx),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  controller.dispose();
}
