import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Main bottom navigation bar.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Discover',
    ),
    (
      icon: Icons.folder_copy_outlined,
      activeIcon: Icons.folder_copy_rounded,
      label: 'My Projects',
    ),
    (
      icon: Icons.groups_2_outlined,
      activeIcon: Icons.groups_2_rounded,
      label: 'My Teams',
    ),
    (
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Saved',
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == currentIndex
                              ? _items[i].activeIcon
                              : _items[i].icon,
                          size: 22,
                          color: i == currentIndex
                              ? c.primary
                              : c.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: i == currentIndex
                              ? AppStyles.caption10Bold(
                                  context,
                                  color: c.primary,
                                )
                              : AppStyles.caption10Secondary(context),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
