import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/project_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../status_chip.dart';

// Showcase card displaying completed/shipped project logo, summary, awards, and live link.
class ProductShowcaseCard extends StatelessWidget {
  const ProductShowcaseCard({
    super.key,
    required this.project,
    required this.canEdit,
    required this.onEdit,
  });

  final ProjectModel project;
  final bool canEdit;
  final VoidCallback onEdit;

  Future<void> _openProductUrl(BuildContext context) async {
    final raw = project.productUrl.trim();
    if (raw.isEmpty) return;
    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppFeedback.show(
        context,
        message: 'Could not open product link',
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final outcome = project.outcome ?? ProjectOutcome.completed;
    final accent = switch (outcome) {
      ProjectOutcome.shipped => c.primary,
      ProjectOutcome.completed => c.success,
      ProjectOutcome.archived => c.textSecondary,
    };

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (project.productLogoUrl.isNotEmpty) ...[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    project.productLogoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.rocket_launch_outlined, color: c.primary),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome == ProjectOutcome.shipped
                          ? 'Shipped Product'
                          : 'Project Delivery',
                      style: AppStyles.title15Bold(context),
                    ),
                    if (project.period.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        project.period,
                        style: AppStyles.body12Secondary(context),
                      ),
                    ],
                  ],
                ),
              ),
              StatusChip(
                label: outcome.label,
                color: accent,
                background: c.subtle(accent),
              ),
            ],
          ),
          if (project.completionSummary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              project.completionSummary,
              style: AppStyles.body13Primary(context),
            ),
          ],
          if (project.awards.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Awards & Achievements',
              style: AppStyles.body12Bold(context, color: c.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: project.awards
                  .map(
                    (award) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: c.subtle(c.warning),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: c.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 14,
                            color: c.warning,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              award,
                              style: AppStyles.body12Medium(
                                context,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (project.productUrl.isNotEmpty || canEdit) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (project.productUrl.isNotEmpty)
                  Expanded(
                    child: AppButton(
                      label: 'Open Live Product',
                      onPressed: () => _openProductUrl(context),
                    ),
                  ),
                if (project.productUrl.isNotEmpty && canEdit)
                  const SizedBox(width: 8),
                if (canEdit)
                  Expanded(
                    child: AppButton(
                      label: 'Edit Showcase',
                      outlined: true,
                      color: c.primary,
                      onPressed: onEdit,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
