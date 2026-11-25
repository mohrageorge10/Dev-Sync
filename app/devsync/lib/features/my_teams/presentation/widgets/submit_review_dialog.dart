import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Result returned from the Submit for Review dialog.
typedef ReviewSubmission = ({bool confirmed, String? prUrl});

// Smart dialog asking whether the member pushed code & opened a PR before moving to In Review.
Future<ReviewSubmission?> showSubmitForReviewDialog(
  BuildContext context, {
  String? existingPrUrl,
}) {
  return showDialog<ReviewSubmission>(
    context: context,
    builder: (_) => _SubmitReviewDialog(existingPrUrl: existingPrUrl),
  );
}

class _SubmitReviewDialog extends StatefulWidget {
  const _SubmitReviewDialog({this.existingPrUrl});

  final String? existingPrUrl;

  @override
  State<_SubmitReviewDialog> createState() => _SubmitReviewDialogState();
}

class _SubmitReviewDialogState extends State<_SubmitReviewDialog> {
  late final TextEditingController _prController;
  bool? _hasPushedPr;

  @override
  void initState() {
    super.initState();
    _prController = TextEditingController(text: widget.existingPrUrl ?? '');
    if (widget.existingPrUrl?.trim().isNotEmpty == true) {
      _hasPushedPr = true;
    }
  }

  @override
  void dispose() {
    _prController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AlertDialog(
      backgroundColor: c.backgroundPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Move to In Review?',
        style: AppStyles.title17Bold(context),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Did you push your changes and open a Pull Request on GitHub?',
              style: AppStyles.body13Secondary(context),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ChoicePill(
                    label: 'Yes, PR opened',
                    icon: Icons.check_circle_outline,
                    selected: _hasPushedPr == true,
                    activeColor: c.success,
                    onTap: () => setState(() => _hasPushedPr = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ChoicePill(
                    label: 'Not yet',
                    icon: Icons.schedule_rounded,
                    selected: _hasPushedPr == false,
                    activeColor: c.warning,
                    onTap: () => setState(() => _hasPushedPr = false),
                  ),
                ),
              ],
            ),
            if (_hasPushedPr == true) ...[
              const SizedBox(height: 14),
              AppInputField(
                controller: _prController,
                label: 'Pull Request URL',
                trailingLabel: 'Optional',
                hint: 'https://github.com/org/repo/pull/12',
                prefixIcon: Icons.link_rounded,
              ),
            ],
            if (_hasPushedPr == false) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.subtle(c.warning),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.warning.withValues(alpha: 0.35)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: c.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No push or PR linked yet. Do you still want to move this task to In Review anyway?',
                        style: AppStyles.body12Medium(
                          context,
                          color: c.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text('Cancel', style: AppStyles.body14Secondary(context)),
        ),
        if (_hasPushedPr != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop((
              confirmed: true,
              prUrl: _hasPushedPr == true ? _prController.text.trim() : null,
            )),
            child: Text(
              _hasPushedPr == true ? 'Submit for Review' : 'Move Anyway',
              style: AppStyles.body14Bold(
                context,
                color: _hasPushedPr == true ? c.primary : c.warning,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? c.subtle(activeColor) : c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? activeColor : c.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? activeColor : c.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.body11Bold(
                  context,
                  color: selected ? activeColor : c.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog for Owner to request changes on an In Review task with an optional note.
Future<String?> showRequestChangesDialog(BuildContext context) async {
  final controller = TextEditingController();
  final c = context.colors;
  final result = await showDialog<String?>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: c.backgroundPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Request changes?', style: AppStyles.title17Bold(ctx)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This task will move back to In Progress for the assignee.',
            style: AppStyles.body13Secondary(ctx),
          ),
          const SizedBox(height: 12),
          AppInputField(
            controller: controller,
            label: 'Review Note',
            trailingLabel: 'Optional',
            hint: 'e.g. Please handle null state on empty list',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text('Cancel', style: AppStyles.body14Secondary(ctx)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: Text(
            'Send Back',
            style: AppStyles.body14Bold(ctx, color: c.warning),
          ),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
