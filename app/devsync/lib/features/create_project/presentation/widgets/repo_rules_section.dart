import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Collapsible card for repository URL, clone link, base branch, and Git rules in Create Project.
class RepoRulesSection extends StatefulWidget {
  const RepoRulesSection({super.key});

  @override
  State<RepoRulesSection> createState() => _RepoRulesSectionState();
}

class _RepoRulesSectionState extends State<RepoRulesSection> {
  late final TextEditingController _repo;
  late final TextEditingController _clone;
  late final TextEditingController _branch;
  late final TextEditingController _prefix;
  final TextEditingController _customRule = TextEditingController();
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<DraftCubit>().state.draft;
    _repo = TextEditingController(text: draft.repoUrl);
    _clone = TextEditingController(text: draft.cloneUrl);
    _branch = TextEditingController(text: draft.defaultBranch);
    _prefix = TextEditingController(text: draft.branchPrefix);
  }

  @override
  void dispose() {
    _repo.dispose();
    _clone.dispose();
    _branch.dispose();
    _prefix.dispose();
    _customRule.dispose();
    super.dispose();
  }

  void _addRule(DraftCubit cubit) {
    final text = _customRule.text.trim();
    if (text.isEmpty) return;
    cubit.addCustomRule(text);
    _customRule.clear();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = context.watch<DraftCubit>().state.draft;
    final cubit = context.read<DraftCubit>();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.code_rounded, size: 18, color: c.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repository & Git Rules',
                        style: AppStyles.body13Bold(context),
                      ),
                      Text(
                        draft.repoUrl.trim().isNotEmpty
                            ? '${draft.activeGitRules.length} rules • ${draft.defaultBranch}'
                            : 'Optional • Add repo, clone URL & branch rules',
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: c.textSecondary,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 14),
            Divider(height: 1, color: c.border),
            const SizedBox(height: 14),
            AppInputField(
              controller: _repo,
              label: 'Repository URL',
              trailingLabel: 'Optional',
              hint: 'https://github.com/org/repo',
              prefixIcon: Icons.link_rounded,
              onChanged: cubit.setRepoUrl,
            ),
            const SizedBox(height: 12),
            AppInputField(
              controller: _clone,
              label: 'Clone URL',
              trailingLabel: 'Auto-filled if empty',
              hint: 'https://github.com/org/repo.git',
              prefixIcon: Icons.terminal_rounded,
              onChanged: cubit.setCloneUrl,
            ),
            const SizedBox(height: 12),
            AppInputField(
              controller: _branch,
              label: 'Base Branch',
              hint: 'develop',
              prefixIcon: Icons.account_tree_outlined,
              onChanged: cubit.setDefaultBranch,
            ),
            const SizedBox(height: 14),
            Text(
              'Git & Collaboration Rules',
              style: AppStyles.body12Bold(context),
            ),
            const SizedBox(height: 6),
            _RuleSwitch(
              title: 'Require Feature Branches',
              subtitle: 'Separate branch per task (${draft.branchPrefix})',
              value: draft.requireFeatureBranches,
              onChanged: cubit.setRequireFeatureBranches,
            ),
            if (draft.requireFeatureBranches) ...[
              const SizedBox(height: 6),
              AppInputField(
                controller: _prefix,
                label: 'Branch Naming Pattern',
                hint: 'feature/<name>',
                onChanged: cubit.setBranchPrefix,
              ),
              const SizedBox(height: 6),
            ],
            _RuleSwitch(
              title: 'No Direct Push / Merge',
              subtitle: 'Block direct pushes or merges to main / develop',
              value: draft.blockDirectMainMerge,
              onChanged: cubit.setBlockDirectMainMerge,
            ),
            _RuleSwitch(
              title: 'PR & Review Required',
              subtitle: 'Require Pull Request and Owner approval before merge',
              value: draft.requirePrReview,
              onChanged: cubit.setRequirePrReview,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customRule,
                    style: AppStyles.body13Primary(context),
                    onSubmitted: (_) => _addRule(cubit),
                    decoration: InputDecoration(
                      hintText: 'Add a custom rule (e.g. Run tests first)...',
                      hintStyle: AppStyles.body12Secondary(context),
                      filled: true,
                      fillColor: c.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _addRule(cubit),
                  style: IconButton.styleFrom(
                    backgroundColor: c.subtleBlueSurface,
                    foregroundColor: c.primary,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 20),
                ),
              ],
            ),
            if (draft.customRules.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (var i = 0; i < draft.customRules.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: c.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          draft.customRules[i],
                          style: AppStyles.body12Primary(context),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: c.textSecondary,
                        ),
                        onPressed: () => cubit.removeCustomRule(i),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RuleSwitch extends StatelessWidget {
  const _RuleSwitch({
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body12Bold(context)),
                Text(subtitle, style: AppStyles.body11Secondary(context)),
              ],
            ),
          ),
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
