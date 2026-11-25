import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/presentation/widgets/bookmark_button.dart';
import 'package:devsync/features/discover_project/presentation/widgets/info_banner.dart';
import 'package:flutter/material.dart';

// Project card in the discover search list.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    this.isSaved = false,
    this.isApplied = false,
    this.onTap,
    this.onApply,
    this.onBookmark,
  });

  final ProjectModel project;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
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
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body14Secondary(context),
          ),
          const SizedBox(height: 12),
          InfoBanner(text: project.matchReason, singleLine: true),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in project.tags) AppSkillChip(label: t)],
          ),
          const SizedBox(height: 16),
          _footer(context, c),
        ],
      ),
    ),
    );
  }

  Widget _header(BuildContext context, AppColors c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: c.subtleBlueSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(project.icon, color: c.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              project.type.toLowerCase() == 'learning'
                  ? AppBadge.learning(context)
                  : AppBadge.realWorld(context),
              const SizedBox(height: 6),
              Text(project.title, style: AppStyles.title16Bold(context)),
              const SizedBox(height: 4),
              Text(
                '${project.createdAgo} • ${project.status}',
                style: AppStyles.body12Secondary(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _matchBadge(context, c),
      ],
    );
  }

  Widget _matchBadge(BuildContext context, AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              value: project.matchPercent / 100,
              strokeWidth: 2.5,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${project.matchPercent}%',
            style: AppStyles.body12Bold(context),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context, AppColors c) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 16, color: c.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${project.members}/${project.maxMembers} members',
                    style: AppStyles.body12Secondary(context),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Needs: ${project.needs}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.body12SemiBold(context, color: c.primary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        BookmarkButton(isSaved: isSaved, onTap: onBookmark),
        const SizedBox(width: 8),
        isApplied
            ? GestureDetector(
                onTap: onApply,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: c.subtle(c.success),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Applied',
                    style: AppStyles.body14Bold(context, color: c.success),
                  ),
                ),
              )
            : AppPrimaryButton(
                buttonText: 'Apply',
                isDisabled: false,
                onPressed: onApply ?? () {},
              ),
      ],
    );
  }
}