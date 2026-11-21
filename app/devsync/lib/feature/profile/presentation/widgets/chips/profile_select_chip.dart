import 'package:flutter/material.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';

class SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool expand;
  final IconData? icon;
  final bool pill;
  final bool showCheck;
  const SelectChip(this.label,
      {super.key, required this.selected, required this.onTap, this.expand = false, this.icon, this.pill = true, this.showCheck = true});

  @override
  Widget build(BuildContext context) {
    if (pill && !expand && icon == null) {
      return AppSkillChip(
        label: label,
        selected: selected,
        onTap: onTap,
      );
    }
    final c = context.colors;
    final fg = selected ? Colors.white : c.textPrimary;
    final selColor = pill ? c.primaryPressed : c.primary;
    final chip = InkWell(
      borderRadius: BorderRadius.circular(pill ? 24 : 10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: pill ? 14 : 12, vertical: pill ? 9 : 12),
        decoration: BoxDecoration(
          color: selected ? selColor : c.subtleBlueSurface,
          borderRadius: BorderRadius.circular(pill ? 24 : 10),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (selected && showCheck) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.check, size: 14, color: Colors.white))
          else if (!selected && icon != null) Padding(padding: const EdgeInsets.only(right: 5), child: Icon(icon, size: 14, color: c.textSecondary)),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: fg))),
        ]),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: chip) : chip;
  }
}
