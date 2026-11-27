import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/project_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../status_chip.dart';

// Completed, shipped, or archived project card displayed in the Previous tab.
class PreviousProjectCard extends StatelessWidget {
  const PreviousProjectCard({
    super.key,
    required this.project,
    required this.onView,
  });

  final ProjectModel project;
  final VoidCallback onView;

  Future<void> _openProduct(BuildContext context) async {
    final raw = project.productUrl.trim();
    if (raw.isEmpty) return;
    final normalized = raw.startsWith('http://') || raw.startsWith('https://')
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
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
    final chipColor = switch (outcome) {
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    project.productLogoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.rocket_launch_outlined,
                      size: 20,
                      color: c.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: AppStyles.title16Bold(context),
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
              const SizedBox(width: 8),
              StatusChip(
                label: project.statusText,
                color: chipColor,
                background: c.subtle(chipColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.completionSummary.isNotEmpty
                ? project.completionSummary
                : project.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body13Primary(context),
          ),
          if (project.awards.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.awards
                  .map(
                    (award) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.subtle(c.warning),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: c.warning.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 13,
                            color: c.warning,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              award,
                              style: AppStyles.body11Medium(
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
          const SizedBox(height: 12),
          Row(
            children: [
              if (project.productUrl.isNotEmpty) ...[
                Expanded(
                  child: AppButton(
                    label: 'Open Product',
                    onPressed: () => _openProduct(context),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: AppButton(
                  label: 'View Project',
                  outlined: true,
                  onPressed: onView,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
