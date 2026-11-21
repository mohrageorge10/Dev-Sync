import 'package:flutter/material.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';

class StepFooter extends StatelessWidget {
  final VoidCallback onContinue;
  final String? blockedReason;
  final String continueLabel;
  final bool showBack;
  const StepFooter({super.key, required this.onContinue, this.blockedReason, this.continueLabel = 'Continue', this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      if (showBack && Navigator.canPop(context)) ...[
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: c.surface, foregroundColor: c.textPrimary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(context),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.arrow_back, size: 16),
                SizedBox(width: 6),
                Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
      Expanded(
        flex: 3,
        child: AppPrimaryButton(
          buttonText: continueLabel,
          trailingIcon: Icons.arrow_forward,
          isDisabled: false,
          onPressed: () {
            if (blockedReason != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(blockedReason!), behavior: SnackBarBehavior.floating));
              return;
            }
            onContinue();
          },
        ),
      ),
    ]);
  }
}
