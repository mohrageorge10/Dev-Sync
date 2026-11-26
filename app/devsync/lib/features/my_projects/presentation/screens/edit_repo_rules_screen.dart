import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/project_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/edit_repo_rules_screen/custom_rules_section_card.dart';
import '../widgets/edit_repo_rules_screen/git_rules_section_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';

// Owner-only screen for editing repository URL, clone link, and Git contribution rules.
class EditRepoRulesScreen extends StatefulWidget {
  const EditRepoRulesScreen({super.key, required this.project});

  final ProjectModel project;

  @override
  State<EditRepoRulesScreen> createState() => _EditRepoRulesScreenState();
}

class _EditRepoRulesScreenState extends State<EditRepoRulesScreen> {
  late final TextEditingController _repoController;
  late final TextEditingController _cloneController;
  late final TextEditingController _branchController;
  late final TextEditingController _prefixController;
  late final TextEditingController _customRuleController;

  late bool _requireBranches;
  late bool _blockDirectMerge;
  late bool _requirePrReview;
  late List<String> _customRules;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _repoController = TextEditingController(text: p.repoUrl);
    _cloneController = TextEditingController(text: p.cloneUrl);
    _branchController = TextEditingController(text: p.defaultBranch);
    _prefixController = TextEditingController(text: p.gitRules.branchPrefix);
    _customRuleController = TextEditingController();

    _requireBranches = p.gitRules.requireFeatureBranches;
    _blockDirectMerge = p.gitRules.blockDirectMainMerge;
    _requirePrReview = p.gitRules.requirePrReview;
    _customRules = List<String>.from(p.gitRules.customRules);
  }

  @override
  void dispose() {
    _repoController.dispose();
    _cloneController.dispose();
    _branchController.dispose();
    _prefixController.dispose();
    _customRuleController.dispose();
    super.dispose();
  }

  void _addCustomRule() {
    final text = _customRuleController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _customRules.add(text);
      _customRuleController.clear();
    });
  }

  Future<void> _save() async {
    final rules = GitWorkflowRules(
      requireFeatureBranches: _requireBranches,
      branchPrefix: _prefixController.text.trim().isEmpty
          ? 'feature/<name>'
          : _prefixController.text.trim(),
      blockDirectMainMerge: _blockDirectMerge,
      requirePrReview: _requirePrReview,
      customRules: _customRules,
    );
    await context.read<MyProjectsCubit>().updateRepoAndRules(
      widget.project.id,
      repoUrl: _repoController.text,
      cloneUrl: _cloneController.text,
      defaultBranch: _branchController.text,
      gitRules: rules,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Repository & Git Rules',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Repository Links'),
                AppInputField(
                  controller: _repoController,
                  label: 'Repository URL',
                  hint: 'https://github.com/org/repo',
                  prefixIcon: Icons.link_rounded,
                ),
                const SizedBox(height: 12),
                AppInputField(
                  controller: _cloneController,
                  label: 'Clone URL',
                  trailingLabel: 'Auto-filled if empty',
                  hint: 'https://github.com/org/repo.git',
                  prefixIcon: Icons.terminal_rounded,
                ),
                const SizedBox(height: 12),
                AppInputField(
                  controller: _branchController,
                  label: 'Default / Base Branch',
                  hint: 'develop',
                  prefixIcon: Icons.account_tree_outlined,
                ),
              ],
            ),
          ),
          GitRulesSectionCard(
            requireBranches: _requireBranches,
            blockDirectMerge: _blockDirectMerge,
            requirePrReview: _requirePrReview,
            prefixController: _prefixController,
            onRequireBranchesChanged: (v) =>
                setState(() => _requireBranches = v),
            onBlockDirectMergeChanged: (v) =>
                setState(() => _blockDirectMerge = v),
            onRequirePrReviewChanged: (v) =>
                setState(() => _requirePrReview = v),
          ),
          CustomRulesSectionCard(
            controller: _customRuleController,
            rules: _customRules,
            onAdd: _addCustomRule,
            onRemoveAt: (i) => setState(() => _customRules.removeAt(i)),
          ),
          const SizedBox(height: 4),
          AppButton(label: 'Save Repository & Rules', onPressed: _save),
        ],
      ),
    );
  }
}
