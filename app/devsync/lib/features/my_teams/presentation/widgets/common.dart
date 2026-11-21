import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Card container with customizable padding, border, and background
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color = AppPalette.surface,
    this.borderColor = AppPalette.border,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Badge pill wrapper delegating to AppBadge
class Pill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  final IconData? icon;
  final double fontSize;
  const Pill(
    this.text, {
    super.key,
    this.fg = AppPalette.primary,
    this.bg = AppPalette.softBlue,
    this.icon,
    this.fontSize = 10.5,
  });

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: text,
      color: fg,
      backgroundColor: bg,
      icon: icon,
    );
  }
}

// Section header with title, trailing text, and optional badge
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget? badge;
  const SectionHeader(this.title, {super.key, this.trailing, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Row(children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        if (badge != null) ...[const SizedBox(width: 6), badge!],
        const Spacer(),
        if (trailing != null)
          Text(trailing!,
              style: const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
      ]),
    );
  }
}

// Primary button delegating to AppPrimaryButton
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool compact;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      buttonText: label,
      leadingIcon: icon,
      isDisabled: false,
      onPressed: onPressed,
    );
  }
}

// Secondary button delegating to AppSecondaryButton
class SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color fg;
  final Color bg;
  const SoftButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fg = AppPalette.primary,
    this.bg = AppPalette.softBlue,
  });

  @override
  Widget build(BuildContext context) {
    return AppSecondaryButton(
      buttonText: label,
      leadingIcon: icon,
      onPressed: onPressed,
    );
  }
}

// Circular avatar displaying user initials
class Avatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color bg;
  final Color fg;
  const Avatar(this.initials,
      {super.key,
      this.size = 28,
      this.bg = AppPalette.softBlue,
      this.fg = AppPalette.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(initials,
          style: TextStyle(
              color: fg, fontSize: size * 0.34, fontWeight: FontWeight.w700)),
    );
  }
}

// Overlapping horizontal avatar stack with overflow counter
class AvatarStack extends StatelessWidget {
  final List<String> initials;
  final int extra;
  final double size;
  const AvatarStack(
    {super.key, required this.initials, this.extra = 0, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final items = [...initials, if (extra > 0) '+$extra'];
    final hasExtra = extra > 0;
    return SizedBox(
      height: size,
      width: size + (items.length - 1) * (size * 0.72),
      child: Stack(children: [
        for (var i = 0; i < items.length; i++)
          Positioned(
            left: i * size * 0.72,
            child: Avatar(items[i],
                size: size,
                bg: i == items.length - 1 && hasExtra
                    ? AppPalette.border
                    : AppPalette.softBlue,
                fg: i == items.length - 1 && hasExtra
                    ? AppPalette.muted
                    : AppPalette.primary),
          ),
      ]),
    );
  }
}

// Linear progress indicator bar
class ProgressLine extends StatelessWidget {
  final double value;
  const ProgressLine(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 5,
        backgroundColor: AppPalette.border,
        valueColor: const AlwaysStoppedAnimation(AppPalette.primary),
      ),
    );
  }
}

// Information strip with icon, left label, and optional right text
class InfoStrip extends StatelessWidget {
  final IconData icon;
  final String left;
  final String? right;
  const InfoStrip(
      {super.key, required this.icon, required this.left, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: AppPalette.primary),
        const SizedBox(width: 6),
        Text(left, style: const TextStyle(fontSize: 11.5)),
        const Spacer(),
        if (right != null)
          Text(right!,
              style: const TextStyle(fontSize: 10.5, color: AppPalette.muted)),
      ]),
    );
  }
}

// Standard top app bar with back navigation and actions
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  const AppTopBar(this.title, {super.key, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () => Navigator.of(context).pop())
          : null,
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }
}

// Helper to display a transient floating SnackBar
void showSnack(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)));
}
