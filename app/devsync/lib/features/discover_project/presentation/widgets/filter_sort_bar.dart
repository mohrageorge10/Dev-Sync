import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Filter trigger button and sort dropdown bar.
class FilterSortBar extends StatelessWidget {
  const FilterSortBar({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    this.filterCount = 0,
    this.onFilterTap,
    this.sortOptions = const ['Recommended', 'Best Match', 'Newest'],
  });

  final int filterCount;
  final VoidCallback? onFilterTap;
  final String selectedSort;
  final List<String> sortOptions;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_filterButton(context, c), _sortButton(context, c)],
    );
  }

  Widget _filterButton(BuildContext context, AppColors c) {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 18, color: c.primary),
            const SizedBox(width: 6),
            Text('Filter', style: AppStyles.body13SemiBold(context)),
            if (filterCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$filterCount',
                  style: AppStyles.body11Bold(context, color: c.onPrimary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sortButton(BuildContext context, AppColors c) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      offset: const Offset(0, 40),
      color: c.backgroundPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final option in sortOptions)
          PopupMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: option == selectedSort
                  ? AppStyles.body13Bold(context, color: c.primary)
                  : AppStyles.body13Primary(context),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort:', style: AppStyles.body13Secondary(context)),
            const SizedBox(width: 4),
            Text(
              selectedSort,
              style: AppStyles.body13Bold(context, color: c.primary),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down, size: 18, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}