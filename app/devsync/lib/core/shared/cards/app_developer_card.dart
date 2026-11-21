import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Developer profile summary card.
class DeveloperProfileCard extends StatelessWidget {
  const DeveloperProfileCard({
    super.key,
    required this.name,
    required this.username,
    required this.title,
    required this.skills,
    required this.avatarUrl,
    this.githubConnected = false,
    this.matchPercent,
    this.matchReason,
  });

  final String name, username, title, avatarUrl;
  final List<String> skills;
  final bool githubConnected;
  final int? matchPercent;
  final String? matchReason;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasAvatar = avatarUrl.trim().isNotEmpty;
    final avatarColor = AppColors.avatarColorFor(name);
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor:
                    hasAvatar ? c.subtleBlueSurface : c.subtle(avatarColor),
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        initial,
                        style: AppStyles.avatarInitials(32, avatarColor),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppStyles.h3(context)),
                    Text('@$username',
                        style: AppStyles.body14Secondary(context)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.terminal_rounded, size: 20, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.title16SemiBold(context, color: c.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in skills.take(3))
                AppBadge(
                  label: s,
                  color: c.textSecondary,
                  backgroundColor: c.surface,
                  showBorder: true,
                ),
            ],
          ),
          if (matchPercent != null && matchReason != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$matchPercent% Team Compatibility ',
                      style: AppStyles.body14Bold(context, color: c.primary),
                    ),
                    TextSpan(text: matchReason),
                  ],
                ),
                style: AppStyles.body13Primary(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}