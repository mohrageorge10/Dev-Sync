import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary)),
                    Text('@$username',
                        style: TextStyle(fontSize: 14, color: c.textSecondary)),
                  ],
                ),
              ),
              if (githubConnected)
                AppBadge(
                  label: 'GitHub',
                  icon: Icons.code,
                  color: c.textSecondary,
                  backgroundColor: c.backgroundPrimary,
                  showBorder: true,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.terminal_rounded, size: 20, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: c.primary)),
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
                TextSpan(children: [
                  TextSpan(
                    text: '$matchPercent% Team Compatibility ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: c.primary),
                  ),
                  TextSpan(text: matchReason),
                ]),
                style: TextStyle(fontSize: 14, color: c.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}