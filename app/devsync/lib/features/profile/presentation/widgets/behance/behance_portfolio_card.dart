import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/behance_profile.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Displays connected Behance handle, design tools, and featured portfolio shots.
class BehancePortfolioCard extends StatelessWidget {
  const BehancePortfolioCard({super.key, required this.behance});

  final BehanceProfile behance;

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      AppFeedback.show(
        context,
        message: 'Could not open Behance link.',
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Bē',
                  style: AppStyles.body13Bold(context, color: c.onPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${behance.username}',
                      style: AppStyles.body13Bold(context),
                    ),
                    Text(
                      'behance.net/${behance.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.body11Secondary(context),
                    ),
                  ],
                ),
              ),
              const ProfileTag('Design Portfolio'),
            ],
          ),
          if (behance.tools.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: behance.tools
                  .map(
                    (tool) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tool,
                        style: AppStyles.body11Medium(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (behance.shots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Featured Case Studies',
              style: AppStyles.body12Bold(context, color: c.textSecondary),
            ),
            const SizedBox(height: 8),
            for (final shot in behance.shots) ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openUrl(
                  context,
                  shot.url.isNotEmpty ? shot.url : behance.profileUrl,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: c.subtleBlueSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: shot.coverUrl.isNotEmpty
                            ? Image.network(
                                shot.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.palette_outlined,
                                  color: c.primary,
                                  size: 20,
                                ),
                              )
                            : Icon(
                                Icons.palette_outlined,
                                color: c.primary,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shot.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.body13Bold(context),
                            ),
                            if (shot.url.isNotEmpty)
                              Text(
                                shot.url.replaceFirst(
                                  RegExp(r'^https?://(www\.)?'),
                                  '',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.body11Secondary(context),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: c.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(context, behance.profileUrl),
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: const Text('View on Behance'),
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
      ),
    );
  }
}
