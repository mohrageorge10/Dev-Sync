import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/project_model.dart';
import '../section_card.dart';
import '../section_title.dart';
import '../status_chip.dart';

// Card displaying repository link, 1-tap git clone command, and Git workflow rules.
class ProjectRepoRulesCard extends StatelessWidget {
  const ProjectRepoRulesCard({
    super.key,
    required this.project,
    this.canEdit = false,
    this.onEdit,
  });

  final ProjectModel project;
  final bool canEdit;
  final VoidCallback? onEdit;

  Future<void> _openRepo(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        AppFeedback.show(
          context,
          message: 'Could not open repository link.',
          type: AppFeedbackType.error,
        );
      }
    }
  }

  Future<void> _copyClone(BuildContext context, String command) async {
    await Clipboard.setData(ClipboardData(text: command));
    if (!context.mounted) return;
    AppFeedback.show(
      context,
      message: 'Clone command copied to clipboard.',
      type: AppFeedbackType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasRepo = project.repoUrl.trim().isNotEmpty;
    final cloneCmd = project.cloneCommand;
    final rules = project.gitRules.activeRuleLines;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code_rounded, size: 18, color: c.primary),
              const SizedBox(width: 6),
              const Expanded(child: SectionTitle('Repository & Git Rules')),
              if (canEdit && onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: c.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: Text(
                    'Edit',
                    style: AppStyles.body12Bold(context, color: c.primary),
                  ),
                ),
            ],
          ),

          // Base branch badge.
          Row(
            children: [
              Text('Base Branch:', style: AppStyles.body12Secondary(context)),
              const SizedBox(width: 8),
              StatusChip(
                label: project.defaultBranch,
                color: c.primary,
                background: c.subtleBlueSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Repository link.
          if (hasRepo) ...[
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _openRepo(context, project.repoUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 16, color: c.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        project.repoUrl.replaceFirst(RegExp(r'^https?://'), ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.body12SemiBold(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 15, color: c.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                canEdit
                    ? 'No repository linked yet. Tap Edit to add repo & clone URLs.'
                    : 'Repository link not added yet.',
                style: AppStyles.body12Secondary(context),
              ),
            ),

          // Clone command box with 1-tap copy.
          if (cloneCmd.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cloneCmd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy clone command',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyClone(context, cloneCmd),
                    icon: Icon(Icons.copy_rounded, size: 16, color: c.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Git & collaboration rules.
          Divider(height: 1, color: c.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.gavel_rounded, size: 15, color: c.textSecondary),
              const SizedBox(width: 6),
              Text('Contribution Rules', style: AppStyles.body13Bold(context)),
            ],
          ),
          const SizedBox(height: 8),
          if (rules.isEmpty)
            Text(
              'No specific Git rules configured.',
              style: AppStyles.body12Secondary(context),
            )
          else
            for (final rule in rules)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 14,
                        color: c.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: AppStyles.body12Primary(context),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
