import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Action footer for the filter bottom sheet.
class FilterFooter extends StatelessWidget {
  const FilterFooter({
    super.key,
    required this.resultsCount,
    this.onClearAll,
    this.onApply,
  });

  final int resultsCount;
  final VoidCallback? onClearAll;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          AppTextButton(
            buttonText: 'Clear All',
            onPressed: onClearAll ?? () {},
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppPrimaryButton(
              buttonText: 'Apply Filters ($resultsCount)',
              trailingIcon: Icons.arrow_forward,
              isDisabled: false,
              onPressed: onApply ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}