import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/core/utils/validators.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/project_strength_meter.dart';
import 'package:devsync/features/create_project/presentation/widgets/repo_rules_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 1: Project details screen.
class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key, this.onNext, this.embedded = false});

  final VoidCallback? onNext;
  final bool embedded;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  late final _title = TextEditingController(
    text: context.read<DraftCubit>().state.draft.title,
  );
  late final _desc = TextEditingController(
    text: context.read<DraftCubit>().state.draft.description,
  );

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  // Open unified global calendar date picker.
  Future<void> _pickEndDate(BuildContext context, DateTime? current) async {
    final notifier = context.read<DraftCubit>();
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: current != null && current.isAfter(now)
          ? current
          : now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
      helpText: 'EXPECTED END DATE',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
    );
    if (picked != null) notifier.setExpectedEndDate(picked);
  }

  // Format date as DD Mon YYYY.
  String _formatDate(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = context.watch<DraftCubit>().state.draft;
    final notifier = context.read<DraftCubit>();
    final hasDate = draft.expectedEndDate != null;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Header.
        Text('Define Your Project', style: AppStyles.h2(context)),
        const SizedBox(height: 4),
        Text(
          'Share your vision and core setup. Your track (${draft.ownerTrack.label}) is assigned automatically from your profile.',
          style: AppStyles.body12Secondary(context),
        ),
        if (!widget.embedded) ...[
          const SizedBox(height: 14),
          const ProjectStrengthMeter(),
        ],
        const SizedBox(height: 18),

        // Title field.
        AppInputField(
          controller: _title,
          label: 'Project Title',
          hint: 'e.g. EcoTrack Mobile: Carbon Analytics',
          prefixIcon: Icons.title_rounded,
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProjectDraft.maxTitleLength),
          ],
          validator: (v) => AppValidators.validateRequiredField(
            v,
            minLength: ProjectDraft.minTitleLength,
          ),
          onChanged: notifier.setTitle,
        ),
        const SizedBox(height: 16),

        // Description field.
        AppInputField(
          controller: _desc,
          label: 'Project Description',
          trailingLabel: '${draft.description.length}/${ProjectDraft.maxDescription}',
          trailingLabelColor:
              draft.description.length >= ProjectDraft.maxDescription - 20
                  ? c.warning
                  : null,
          hint: 'Describe the problem, core features, and what the team will build...',
          minLines: 3,
          maxLines: 5,
          inputFormatters: [
            LengthLimitingTextInputFormatter(ProjectDraft.maxDescription),
          ],
          validator: (v) => AppValidators.validateRequiredField(
            v,
            minLength: ProjectDraft.minDescriptionLength,
          ),
          onChanged: notifier.setDescription,
        ),
        const SizedBox(height: 16),

        // Purpose selector.
        const _FieldHeader(label: 'Project Purpose', trailing: 'Learning vs Real-world'),
        AppSegmentedControl(
          labels: [for (final p in ProjectPurpose.values) p.label],
          selectedIndex: ProjectPurpose.values.indexOf(draft.purpose),
          onChanged: (i) => notifier.setPurpose(ProjectPurpose.values[i]),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: c.subtleBlueSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Icon(draft.purpose.icon, size: 16, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  draft.purpose.subtitle,
                  style: AppStyles.body12Primary(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Difficulty selector.
        const _FieldHeader(label: 'Project Difficulty', trailing: 'Technical complexity'),
        AppSegmentedControl(
          labels: [for (final d in ProjectDifficulty.values) d.label],
          selectedIndex: ProjectDifficulty.values.indexOf(draft.difficulty),
          onChanged: (i) => notifier.setDifficulty(ProjectDifficulty.values[i]),
        ),
        const SizedBox(height: 16),

        // Expected end date picker field.
        const _FieldHeader(label: 'Expected End Date', trailing: 'Optional'),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickEndDate(context, draft.expectedEndDate),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: hasDate ? c.backgroundPrimary : c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasDate ? c.primary : c.border,
                width: hasDate ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 22,
                  color: hasDate ? c.primary : c.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasDate
                        ? _formatDate(draft.expectedEndDate!)
                        : 'Select a target completion date',
                    style: AppStyles.body15(context, active: hasDate),
                  ),
                ),
                if (hasDate)
                  GestureDetector(
                    onTap: () => notifier.setExpectedEndDate(null),
                    child: Icon(Icons.close_rounded, size: 18, color: c.textSecondary),
                  )
                else
                  Text(
                    'Pick Date',
                    style: AppStyles.body12SemiBold(context, color: c.primary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Repository, clone link, and Git contribution rules.
        const RepoRulesSection(),
        const SizedBox(height: 24),

        // Continue button.
        AppPrimaryButton(
          buttonText: 'Continue to Team Formation',
          trailingIcon: Icons.arrow_forward,
          isDisabled: !draft.isValid,
          onPressed: () => widget.onNext?.call(),
        ),
      ],
    );

    return widget.embedded
        ? body
        : Scaffold(appBar: AppBar(title: const Text('Create Project')), body: body);
  }
}

// Field section label.
class _FieldHeader extends StatelessWidget {
  const _FieldHeader({required this.label, this.trailing});
  final String label;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.label14SemiBold(context)),
          if (trailing != null)
            Text(trailing!, style: AppStyles.body12Secondary(context)),
        ],
      ),
    );
  }
}
