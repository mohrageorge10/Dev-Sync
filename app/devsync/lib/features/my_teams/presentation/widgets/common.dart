import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Card container with customizable padding, border, and background.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = 14,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: color ?? c.backgroundPrimary,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? c.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Compact status/tag pill with ellipsis overflow safety.
class Pill extends StatelessWidget {
  const Pill(
    this.text, {
    super.key,
    this.fg,
    this.bg,
    this.icon,
    this.fontSize = 11,
  });

  final String text;
  final Color? fg;
  final Color? bg;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final foreground = fg ?? c.primary;
    final background = bg ?? c.subtleBlueSurface;
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 2, color: foreground),
                const SizedBox(width: 4),
              ],
              if (constraints.hasBoundedWidth)
                Flexible(child: label)
              else
                label,
            ],
          ),
        );
      },
    );
  }
}

// Section header with title, trailing text, and optional badge.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.badge});

  final String title;
  final String? trailing;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Row(
        children: [
          Text(title, style: AppStyles.body13Bold(context)),
          if (badge != null) ...[const SizedBox(width: 6), badge!],
          const Spacer(),
          if (trailing != null)
            Text(trailing!, style: AppStyles.body11Secondary(context)),
        ],
      ),
    );
  }
}

// Circular avatar displaying user initials.
class Avatar extends StatelessWidget {
  const Avatar(
    this.initials, {
    super.key,
    this.size = 28,
    this.bg,
    this.fg,
  });

  final String initials;
  final double size;
  final Color? bg;
  final Color? fg;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg ?? c.subtleBlueSurface,
        shape: BoxShape.circle,
        border: Border.all(color: c.backgroundPrimary, width: 2),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: fg ?? c.primary,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Overlapping horizontal avatar stack with overflow counter.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.initials,
    this.extra = 0,
    this.size = 28,
  });

  final List<String> initials;
  final int extra;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = [...initials, if (extra > 0) '+$extra'];
    if (items.isEmpty) return const SizedBox.shrink();
    final hasExtra = extra > 0;
    return SizedBox(
      height: size,
      width: size + (items.length - 1) * (size * 0.72),
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * size * 0.72,
              child: Avatar(
                items[i],
                size: size,
                bg: i == items.length - 1 && hasExtra
                    ? c.border
                    : c.subtleBlueSurface,
                fg: i == items.length - 1 && hasExtra
                    ? c.textSecondary
                    : c.primary,
              ),
            ),
        ],
      ),
    );
  }
}

// Linear progress indicator bar.
class ProgressLine extends StatelessWidget {
  const ProgressLine(this.value, {super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 5,
        backgroundColor: c.border,
        valueColor: AlwaysStoppedAnimation(c.primary),
      ),
    );
  }
}

// Information strip with icon, left label, and optional right text.
class InfoStrip extends StatelessWidget {
  const InfoStrip({
    super.key,
    required this.icon,
    required this.left,
    this.right,
  });

  final IconData icon;
  final String left;
  final String? right;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: c.primary),
          const SizedBox(width: 6),
          Text(left, style: AppStyles.body12Primary(context)),
          const Spacer(),
          if (right != null)
            Text(right!, style: AppStyles.body11Secondary(context)),
        ],
      ),
    );
  }
}

// Standard top app bar using shared CustomAppBar.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar(this.title, {super.key, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomAppBar(
      title: title,
      showActions: false,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      extraActions: actions,
    );
  }
}

// Helper to display unified floating feedback toast.
void showSnack(
  BuildContext context,
  String msg, {
  AppFeedbackType type = AppFeedbackType.info,
}) {
  AppFeedback.show(context, message: msg, type: type);
}

// Safely launch an external URL (auto-prefixing https:// if missing).
Future<void> openExternalUrl(BuildContext context, String rawUrl) async {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return;
  final normalized =
      trimmed.startsWith('http://') || trimmed.startsWith('https://')
      ? trimmed
      : 'https://$trimmed';
  final uri = Uri.tryParse(normalized);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      showSnack(context, 'Could not open $trimmed', type: AppFeedbackType.error);
    }
  }
}
