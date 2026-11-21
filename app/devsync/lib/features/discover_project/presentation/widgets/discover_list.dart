import 'package:flutter/material.dart';

// Generic scrollable list for discover tabs.
class DiscoverList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget empty;
  final Widget? footer;

  const DiscoverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.empty,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return empty;

    final hasFooter = footer != null;

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length + (hasFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (hasFooter && index == items.length) return footer!;
        return itemBuilder(context, items[index]);
      },
    );
  }
}