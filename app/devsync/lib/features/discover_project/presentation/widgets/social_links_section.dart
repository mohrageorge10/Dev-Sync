import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Connected social accounts section.
class SocialLinksSection extends StatelessWidget {
  final List<SocialLinkItem> items;

  const SocialLinksSection({super.key, required this.items});

  Future<void> _openLink(BuildContext context, SocialLinkItem item) async {
    final opened = await launchUrl(
      Uri.parse(item.url),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      AppFeedback.show(
        context,
        message: 'Could not open the link.',
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openLink(context, item),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.backgroundPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: c.subtleBlueSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: c.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  style: AppStyles.body14Bold(context),
                                ),
                                if (item.isConnected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.subtle(c.success),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: c.success,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Connected',
                                          style: AppStyles.body11Bold(
                                            context,
                                            color: c.success,
                                          ).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: item.isConnected
                                  ? AppStyles.body12Secondary(context)
                                  : AppStyles.body12Medium(
                                      context,
                                      color: c.primary,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(item.trailingIcon, color: c.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
