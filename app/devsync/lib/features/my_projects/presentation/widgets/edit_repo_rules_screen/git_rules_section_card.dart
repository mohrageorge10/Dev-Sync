import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card containing standard Git workflow rule toggles and branch prefix field.
class GitRulesSectionCard extends StatelessWidget {
  const GitRulesSectionCard({
    super.key,
    required this.requireBranches,
    required this.blockDirectMerge,
    required this.requirePrReview,
    required this.prefixController,
    required this.onRequireBranchesChanged,
    required this.onBlockDirectMergeChanged,
    required this.onRequirePrReviewChanged,
  });

  final bool requireBranches;
  final bool blockDirectMerge;
  final bool requirePrReview;
  final TextEditingController prefixController;
  final ValueChanged<bool> onRequireBranchesChanged;
  final ValueChanged<bool> onBlockDirectMergeChanged;
  final ValueChanged<bool> onRequirePrReviewChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Git Workflow Rules'),
          _RuleToggleRow(
            title: 'Require Feature Branches',
            subtitle: 'Developers must work on separate branches per task',
            value: requireBranches,
            onChanged: onRequireBranchesChanged,
          ),
          if (requireBranches) ...[
            const SizedBox(height: 8),
            AppInputField(
              controller: prefixController,
              label: 'Branch Naming Pattern',
              hint: 'feature/<name>',
            ),
            const SizedBox(height: 8),
          ],
          Divider(height: 1, color: c.border),
          _RuleToggleRow(
            title: 'No Direct Push / Merge',
            subtitle: 'Block direct pushes or merges into main / develop',
            value: blockDirectMerge,
            onChanged: onBlockDirectMergeChanged,
          ),
          Divider(height: 1, color: c.border),
          _RuleToggleRow(
            title: 'Pull Request & Review Required',
            subtitle: 'Every change must go through a reviewed PR',
            value: requirePrReview,
            onChanged: onRequirePrReviewChanged,
          ),
        ],
      ),
    );
  }
}

class _RuleToggleRow extends StatelessWidget {
  const _RuleToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body13Bold(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppStyles.body11Secondary(context)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: c.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
