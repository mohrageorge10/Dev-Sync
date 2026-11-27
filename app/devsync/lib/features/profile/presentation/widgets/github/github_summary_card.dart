import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Displays GitHub language breakdown and repository activity metrics.
class GithubSummaryCard extends StatelessWidget {
  const GithubSummaryCard({super.key, required this.analysis});

  final GithubAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final entries = analysis.languages.entries.toList();
    final langColors = [
      c.primary,
      c.darkBlueAccent,
      c.primaryPressed,
      c.border,
    ];

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                AppImages.githubLogo,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '@${analysis.username} activity summary',
                  style: AppStyles.body12Bold(context),
                ),
              ),
              ProfileTag('Public data', fg: c.textSecondary, bg: c.surface),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Expanded(
                      flex: entries[i].value.clamp(1, 100),
                      child: Container(
                        height: 6,
                        color: langColors[i % langColors.length],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (var i = 0; i < entries.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: langColors[i % langColors.length],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entries[i].key} ${entries[i].value}%',
                        style: AppStyles.caption10Bold(context),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem('${analysis.repos}', 'Repositories'),
                _StatItem('${analysis.commits}', 'Recent Commits'),
                _StatItem('${analysis.prsMerged}', 'PRs Merged'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppStyles.h20(context)),
        Text(label, style: AppStyles.caption10Secondary(context)),
      ],
    );
  }
}
