import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:flutter/material.dart';

// Portfolio project card on the public profile screen.
class PortfolioProjectCard extends StatelessWidget {
  final PortfolioProjectData project;
  final VoidCallback? onTap;

  const PortfolioProjectCard({super.key, required this.project, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: c.backgroundPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ambientShadow,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppBadge.info(context, project.badgeText),
                        Text(
                          project.statusText,
                          style: AppStyles.body12Medium(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: c.subtleBlueSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(project.topIcon, color: c.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(project.title, style: AppStyles.title16Bold(context)),
              const SizedBox(height: 4),
              Text(
                project.description,
                style: AppStyles.body12Secondary(context),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: c.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        project.roleText,
                        style: AppStyles.body12SemiBold(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        project.trailingInfoIcon,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        project.trailingInfoText,
                        style: AppStyles.body12Medium(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}