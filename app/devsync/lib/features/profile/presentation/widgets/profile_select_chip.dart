import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Selectable pill or grid chip supporting icons and full-width layout.
class ProfileSelectChip extends StatelessWidget {
  const ProfileSelectChip(
    this.label, {
    super.key,
    required this.selected,
    required this.onTap,
    this.expand = false,
    this.icon,
    this.pill = true,
    this.showCheck = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;
  final IconData? icon;
  final bool pill;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    if (pill && !expand && icon == null) {
      return AppSkillChip(label: label, selected: selected, onTap: onTap);
    }

    final c = context.colors;
    final fg = selected ? c.onPrimary : c.textPrimary;
    final selColor = pill ? c.primaryPressed : c.primary;

    final chip = InkWell(
      borderRadius: BorderRadius.circular(pill ? 24 : 10),
      onTap: onTap,
      child: Container(
        alignment: expand ? Alignment.center : null,
        padding: EdgeInsets.symmetric(
          horizontal: pill ? 14 : 12,
          vertical: pill ? 9 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? selColor : c.subtleBlueSurface,
          borderRadius: BorderRadius.circular(pill ? 24 : 10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected && showCheck)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(Icons.check_rounded, size: 14, color: fg),
              )
            else if (!selected && icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(icon, size: 14, color: c.textSecondary),
              ),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: selected
                    ? AppStyles.body12Bold(context, color: fg)
                    : AppStyles.body12Medium(context, color: fg),
              ),
            ),
          ],
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: chip) : chip;
  }
}
