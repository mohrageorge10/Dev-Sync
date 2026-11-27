import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/presentation/widgets/bookmark_button.dart';
import 'package:devsync/features/discover_project/presentation/widgets/info_banner.dart';
import 'package:flutter/material.dart';

// Developer card in the discover search list.
class DeveloperCard extends StatelessWidget {
  const DeveloperCard({
    super.key,
    required this.developer,
    this.isSaved = false,
    this.onViewProfile,
    this.onBookmark,
  });

  final DeveloperModel developer;
  final bool isSaved;
  final VoidCallback? onViewProfile;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onViewProfile,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context, c),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in developer.skills) AppSkillChip(label: s),
              ],
            ),
            if (developer.bio.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoBanner(text: developer.bio),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                buttonText: 'View Profile',
                trailingIcon: Icons.arrow_forward,
                isDisabled: false,
                onPressed: onViewProfile ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppColors c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(c),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                developer.name,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.title16Bold(context),
              ),
              const SizedBox(height: 3),
              Text(
                '${developer.role} • ${developer.level}',
                style: AppStyles.body12Secondary(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        BookmarkButton(isSaved: isSaved, onTap: onBookmark, size: 36),
      ],
    );
  }

  Widget _avatar(AppColors c) {
    final hasAvatar =
        developer.imageUrl != null && developer.imageUrl!.trim().isNotEmpty;
    final avatarColor = AppColors.avatarColorFor(developer.name);
    final initial = developer.name.trim().isNotEmpty
        ? developer.name.trim()[0].toUpperCase()
        : '?';

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                hasAvatar ? c.subtleBlueSurface : c.subtle(avatarColor),
            backgroundImage: hasAvatar ? NetworkImage(developer.imageUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    initial,
                    style: AppStyles.avatarInitials(26, avatarColor),
                  ),
          ),
          if (developer.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: c.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.backgroundPrimary, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}