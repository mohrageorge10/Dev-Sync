import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Empty state view when no projects or developers match filters.
class ProjectsEmptyState extends StatelessWidget {
  const ProjectsEmptyState({
    super.key,
    required this.searchQuery,
    this.entityName = 'projects',
    this.onBrowseAll,
    this.onClearFilters,
  });

  final String searchQuery;
  final String entityName;
  final VoidCallback? onBrowseAll;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _illustration(c),
          const SizedBox(height: 20),
          Text(
            'No $entityName found',
            style: AppStyles.title17Bold(context),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text.rich(
              TextSpan(
                style: AppStyles.body14Secondary(context),
                children: searchQuery.isEmpty
                    ? [
                        TextSpan(
                          text:
                              "We couldn't find any $entityName matching your filters. Try broadening them.",
                        ),
                      ]
                    : [
                        TextSpan(
                          text: "We couldn't find any $entityName matching ",
                        ),
                        TextSpan(
                          text: '"$searchQuery"',
                          style: AppStyles.body14Bold(context),
                        ),
                        const TextSpan(
                          text: '. Try broadening your filters or search terms.',
                        ),
                      ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              buttonText: 'Browse all $entityName',
              leadingIcon: Icons.explore_outlined,
              isDisabled: false,
              onPressed: onBrowseAll ?? () {},
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: AppSecondaryButton(
              buttonText: 'Clear filters',
              leadingIcon: Icons.restart_alt,
              onPressed: onClearFilters ?? () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _illustration(AppColors c) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_outlined, size: 46, color: c.primary),
          ),
          Positioned(
            right: 0,
            bottom: 6,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
                border: Border.all(color: c.backgroundPrimary, width: 3),
              ),
              child: Icon(Icons.search, size: 16, color: c.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}