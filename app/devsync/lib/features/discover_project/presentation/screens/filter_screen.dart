import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_footer.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_header.dart';
import 'package:devsync/features/discover_project/presentation/widgets/filter_sections_list.dart';
import 'package:flutter/material.dart';

// Filter modal bottom sheet for projects and developers.
class FilterScreen extends StatefulWidget {
  final FilterState initial;
  final int Function(FilterState draft) countMatching;
  final ValueChanged<FilterState> onApply;

  const FilterScreen({
    super.key,
    required this.initial,
    required this.countMatching,
    required this.onApply,
  });

  // Present filter sheet.
  static Future<void> show(
    BuildContext context, {
    required FilterState initial,
    required int Function(FilterState draft) countMatching,
    required ValueChanged<FilterState> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FilterScreen(
        initial: initial,
        countMatching: countMatching,
        onApply: onApply,
      ),
    );
  }

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterState _draft = widget.initial;

  @override
  Widget build(BuildContext context) {
    final count = widget.countMatching(_draft);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: FilterHeader(
            activeCount: _draft.activeCount,
            onClose: () => Navigator.pop(context),
          ),
        ),
        Expanded(
          child: FilterSectionsList(
            state: _draft,
            matchingCount: count,
            onChanged: (value) => setState(() => _draft = value),
          ),
        ),
        FilterFooter(
          resultsCount: count,
          onClearAll: () => setState(() => _draft = const FilterState()),
          onApply: () {
            widget.onApply(_draft);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}