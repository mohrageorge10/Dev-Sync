import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/shared/badges/app_level_badge.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Interactive 4-tier experience level meter with rising bars and live rank preview.
class AppLevelMeter extends StatelessWidget {
  const AppLevelMeter({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<String> items;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selectedIndex = selected != null ? items.indexOf(selected!) : -1;
    final activeMeta = selectedIndex >= 0
        ? ExperienceLevelMeta.of(context, items[selectedIndex])
        : null;
    final accent = activeMeta?.color ?? c.primary;

    return AnimatedContainer(
      duration: AppAnimations.normal,
      curve: AppAnimations.easeOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeMeta != null
              ? accent.withValues(alpha: 0.35)
              : c.border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: AppAnimations.normal,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activeMeta != null
                      ? accent.withValues(alpha: 0.14)
                      : c.backgroundPrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activeMeta != null
                        ? accent.withValues(alpha: 0.25)
                        : c.border,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Icon(
                    activeMeta?.icon ?? Icons.signal_cellular_alt_rounded,
                    key: ValueKey(activeMeta?.label ?? 'empty'),
                    size: 20,
                    color: activeMeta != null ? accent : c.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeMeta?.label ?? 'Select your level',
                      style: AppStyles.body14Bold(
                        context,
                        color: activeMeta != null ? accent : c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeMeta?.subtitle ??
                          'Tap any bar below to set your experience tier',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.body11Secondary(context),
                    ),
                  ],
                ),
              ),
              if (activeMeta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Tier ${selectedIndex + 1}/${items.length}',
                    style: AppStyles.caption10Bold(context, color: accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _LevelBarColumn(
                    label: items[i],
                    barHeight: 16.0 + (i * 8.0),
                    isFilled: selectedIndex >= 0 && i <= selectedIndex,
                    isCurrent: i == selectedIndex,
                    accent: accent,
                    onTap: () => onChanged(items[i]),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelBarColumn extends StatelessWidget {
  const _LevelBarColumn({
    required this.label,
    required this.barHeight,
    required this.isFilled,
    required this.isCurrent,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final double barHeight;
  final bool isFilled;
  final bool isCurrent;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: AppAnimations.normal,
                  curve: AppAnimations.easeOut,
                  width: double.infinity,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? (isCurrent ? accent : accent.withValues(alpha: 0.45))
                        : c.border.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: isCurrent
                    ? AppStyles.body11Bold(context, color: accent)
                    : AppStyles.body11Medium(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
