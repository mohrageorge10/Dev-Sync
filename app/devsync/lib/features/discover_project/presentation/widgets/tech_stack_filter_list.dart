import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:flutter/material.dart';

// Horizontal tech stack filter bar.
class TechStackFilterList extends StatelessWidget {
  const TechStackFilterList({
    super.key,
    required this.selected,
    required this.onSelected,
    this.stacks = const [
      'All Stacks',
      'Flutter',
      'Node.js',
      'Go',
      'Python / ML',
      'Web3',
    ],
  });

  final List<String> stacks;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stacks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final stack = stacks[index];
          return Center(
            child: AppSkillChip(
              label: stack,
              selected: stack == selected,
              onTap: () => onSelected(stack),
            ),
          );
        },
      ),
    );
  }
}