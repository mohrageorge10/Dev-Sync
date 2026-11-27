import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Portfolio project card on the public profile screen (supports logos, awards, and product link).
class PortfolioProjectCard extends StatelessWidget {
  final PortfolioProjectData project;
  final VoidCallback? onTap;

  const PortfolioProjectCard({super.key, required this.project, this.onTap});

  Future<void> _openProductUrl(BuildContext context) async {
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
    final statusColor = project.statusText.toLowerCase().contains('shipped')
        ? c.primary
        : project.isCompleted
        ? c.success
        : c.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.backgroundPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ambientShadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: c.subtleBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: project.logoUrl.isNotEmpty
                        ? Image.network(
                            project.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              project.topIcon,
                              color: c.primary,
                              size: 22,
                            ),
                          )
                        : Icon(project.topIcon, color: c.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.title16Bold(context),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          project.badgeText,
                          style: AppStyles.body11Bold(
                            context,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c.subtle(statusColor),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      project.statusText,
                      style: AppStyles.body11Bold(
                        context,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (project.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  project.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.body13Secondary(context),
                ),
              ],
              if (project.awards.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
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
              const SizedBox(height: 12),
              Divider(height: 1, color: c.border),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: c.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        project.roleText,
                        style: AppStyles.body12SemiBold(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        project.trailingInfoIcon,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        project.trailingInfoText,
                        style: AppStyles.body12Medium(context),
                      ),
                    ],
                  ),
                ],
              ),
              if (project.productUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () => _openProductUrl(context),
                    icon: const Icon(Icons.open_in_new_rounded, size: 15),
                    label: const Text('Open Live Product'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.primary,
                      side: BorderSide(color: c.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
