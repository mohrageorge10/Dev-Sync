import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:flutter/material.dart';

// Developer avatar with availability dot.
class BuilderAvatar extends StatelessWidget {
  const BuilderAvatar({super.key, required this.builder, this.radius = 20});

  final DevBuilder builder;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = AppColors.avatarColorFor(builder.id);
    final hasPhoto = builder.photoUrl.trim().isNotEmpty;

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: tint.withValues(alpha: 0.15),
          backgroundImage: hasPhoto ? NetworkImage(builder.photoUrl) : null,
          child: hasPhoto
              ? null
              : Text(
                  builder.initials,
                  style: AppStyles.avatarInitials(radius, tint),
                ),
        ),
        if (builder.availableNow)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: c.success,
                shape: BoxShape.circle,
                border: Border.all(color: c.backgroundPrimary, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// Developer list item row.
class BuilderTile extends StatelessWidget {
  const BuilderTile({
    super.key,
    required this.builder,
    required this.percent,
    required this.selected,
    required this.onTap,
  });

  final DevBuilder builder;
  final int percent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? c.subtleBlueSurface : c.backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? c.primary : c.border),
        ),
        child: Row(
          children: [
            BuilderAvatar(builder: builder),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          builder.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.body13Bold(context),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.subtleBlueSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${builder.track.label} · ${builder.level.label}',
                          style: AppStyles.overline9SemiBold(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${builder.displayHandle} · $percent% match'
                    '${builder.availableNow ? ' · Available' : ''}',
                    style: AppStyles.body11Secondary(context),
                  ),
                  if (builder.skills.isNotEmpty)
                    Text(
                      builder.skills.take(3).join(' · '),
                      style: AppStyles.caption10Secondary(context),
                    ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? c.primary : c.border,
            ),
          ],
        ),
      ),
    );
  }
}
