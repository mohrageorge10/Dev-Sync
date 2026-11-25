import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:flutter/material.dart';

/////----Filter Chips Group----/////
class FilterChipsGroup extends StatelessWidget {
  const FilterChipsGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiSelect = true,
  });

  final List<String> options;
  final Set<String> selected;
  final bool multiSelect;
  final ValueChanged<Set<String>> onChanged;

  void _onChipTap(String option) {
    final Set<String> updated = Set<String>.from(selected);

    if (multiSelect) {
      if (!updated.remove(option)) updated.add(option);
    } else {
      final bool wasSelected = updated.contains(option);
      updated.clear();
      if (!wasSelected) updated.add(option);
    }

    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          AppSkillChip(
            label: option,
            selected: selected.contains(option),
            onTap: () => _onChipTap(option),
          ),
      ],
    );
  }
}