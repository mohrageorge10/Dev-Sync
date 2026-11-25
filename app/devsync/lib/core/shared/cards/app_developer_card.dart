import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Compact developer profile card.
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    hasAvatar ? c.subtleBlueSurface : c.subtle(avatarColor),
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        initial,
                        style: AppStyles.avatarInitials(22, avatarColor),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.title15Bold(context),
                    ),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.body12Medium(context, color: c.primary),
                    ),
                  ],
                ),
              ),
              if (matchPercent != null)
                Text(
                  '$matchPercent%',
                  style: AppStyles.body12Bold(context, color: c.primary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in skills.take(3))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border),
                  ),
                  child: Text(s, style: AppStyles.body11Medium(context)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
