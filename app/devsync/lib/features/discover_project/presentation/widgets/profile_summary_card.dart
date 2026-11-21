import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:flutter/material.dart';

// Developer summary card with avatar, bio, and metrics.
class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key, required this.developer});

  final DeveloperModel developer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = developer;
    final hasAvatar = d.imageUrl != null && d.imageUrl!.trim().isNotEmpty;
    final avatarColor = AppColors.avatarColorFor(d.name);
    final initial =
        d.name.trim().isNotEmpty ? d.name.trim()[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: hasAvatar
                        ? c.subtleBlueSurface
                        : c.subtle(avatarColor),
                    backgroundImage:
                        hasAvatar ? NetworkImage(d.imageUrl!) : null,
                    child: hasAvatar
                        ? null
                        : Text(
                            initial,
                            style: AppStyles.avatarInitials(30, avatarColor),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: c.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: c.backgroundPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            d.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.title16Bold(context),
                          ),
                        ),
                        if (d.hasGithub) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified, color: c.primary, size: 16),
                        ],
                      ],
                    ),
                    Text(d.handle, style: AppStyles.body12Medium(context)),
                    Row(
                      children: [
                        Icon(
                          Icons.terminal_rounded,
                          size: 14,
                          color: c.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            d.subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.body11SemiBold(
                              context,
                              color: c.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(d.bio, style: AppStyles.body13Secondary(context)),
          const SizedBox(height: 12),

          // Developer activity metrics.
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(count: d.repositoriesCount, label: 'Repositories'),
                Container(
                  width: 90,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.backgroundPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _StatItem(
                    count: d.commitsCount,
                    label: 'Commits',
                    isHighlighted: true,
                  ),
                ),
                _StatItem(count: d.projectsCount, label: 'Projects Built'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
    this.isHighlighted = false,
  });

  final String count;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: AppStyles.title17Bold(
            context,
            color: isHighlighted ? c.primary : c.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.body11Medium(context, color: c.textPrimary),
        ),
      ],
    );
  }
}
