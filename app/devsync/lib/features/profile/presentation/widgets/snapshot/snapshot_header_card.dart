import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/badges/app_level_badge.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Profile identity header with avatar, rank badge, track, bio, and completeness bar.
class SnapshotHeaderCard extends StatelessWidget {
  const SnapshotHeaderCard({super.key, required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ImageProvider? avatarImage = profile.avatarBytes != null
        ? MemoryImage(profile.avatarBytes!)
        : (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
        ? NetworkImage(profile.photoUrl!)
        : null;
    final trackLabel = profile.track == null
        ? 'Developer'
        : profile.subTrack != null
        ? '${profile.track} • ${profile.subTrack}'
        : '${profile.track} Developer';

    return ProfileCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: c.subtleBlueSurface,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Icon(Icons.person, color: c.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName.isEmpty
                          ? 'Your name'
                          : profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.title17Bold(context),
                    ),
                    if (profile.username.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: '@${profile.username.trim()}'),
                          );
                          AppFeedback.show(
                            context,
                            message: 'Username copied',
                            type: AppFeedbackType.success,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '@${profile.username.trim()}',
                              style: AppStyles.body12Secondary(context),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.copy, size: 11, color: c.textSecondary),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.terminal_rounded,
                              size: 15,
                              color: c.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              trackLabel,
                              style: AppStyles.body12SemiBold(
                                context,
                                color: c.primary,
                              ),
                            ),
                          ],
                        ),
                        if (profile.level != null)
                          AppLevelBadge(level: profile.level!, compact: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile.bio.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                profile.bio.trim(),
                style: AppStyles.body13Secondary(context),
              ),
            ),
          ],
          if (profile.completion < 100) ...[
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profileComplete),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: c.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Profile Completeness',
                            style: AppStyles.body11Bold(context),
                          ),
                        ),
                        Text(
                          '${profile.completion}%',
                          style: AppStyles.body12Bold(context, color: c.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: profile.completion / 100,
                        minHeight: 5,
                        backgroundColor: c.border,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap to complete your profile for better matches',
                      style: AppStyles.caption10Secondary(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
