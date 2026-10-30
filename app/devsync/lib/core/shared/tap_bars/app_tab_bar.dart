import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.badges = const {},
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Small counter next to a tab, by tab index. Example: {0: 4}
  final Map<int, int> badges;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(
      children: [
        // Gray line under all tabs
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(height: 1, color: c.border),
        ),
        Row(
          children: [
            for (int i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: i == selectedIndex
                              ? c.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: i == selectedIndex
                                  ? c.primary
                                  : c.textSecondary,
                            ),
                          ),
                        ),
                        if (badges[i] != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.subtleBlueSurface,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              '${badges[i]}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}