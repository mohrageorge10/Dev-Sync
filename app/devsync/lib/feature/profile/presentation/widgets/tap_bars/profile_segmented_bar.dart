import 'package:flutter/material.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';

class SegmentedBar extends StatelessWidget {
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onChanged;
  const SegmentedBar({super.key, required this.items, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final idx = selected != null ? items.indexOf(selected!) : 0;
    return AppSegmentedControl(
      labels: items,
      selectedIndex: idx >= 0 ? idx : 0,
      onChanged: (i) => onChanged(items[i]),
    );
  }
}
