import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/selectors/app_level_meter.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Primary button wrapper supporting optional destructive color tint.
class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton(
    this.label, {
    super.key,
    this.onPressed,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (color != null) {
      final disabled = onPressed == null;
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: disabled ? c.subtleBlueSurface : color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    size: 18,
                    color: disabled ? c.textSecondary : c.onPrimary,
                  ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: disabled
                        ? AppStyles.gray_16_500(context)
                        : AppStyles.white_14_500(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppPrimaryButton(
      onPressed: onPressed ?? () {},
      buttonText: label,
      trailingIcon: icon,
      isDisabled: onPressed == null,
    );
  }
}

// Secondary outline/soft button wrapper.
class ProfileSoftButton extends StatelessWidget {
  const ProfileSoftButton(this.label, {super.key, this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return AppSecondaryButton(
      onPressed: onPressed ?? () {},
      buttonText: label,
      leadingIcon: icon,
    );
  }
}

// Small themed badge wrapper.
class ProfileTag extends StatelessWidget {
  const ProfileTag(this.label, {super.key, this.fg, this.bg});

  final String label;
  final Color? fg;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBadge(
      label: label,
      color: fg ?? c.primary,
      backgroundColor: bg ?? c.subtleBlueSurface,
    );
  }
}

// Experience level selector backed by AppLevelMeter.
class ProfileSegmentedBar extends StatelessWidget {
  const ProfileSegmentedBar({
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
    return AppLevelMeter(
      items: items,
      selected: selected,
      onChanged: onChanged,
    );
  }
}
