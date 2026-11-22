import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter/material.dart';

/// App bar of the redesigned AI Match screens: back, title, bell, avatar.
class MatchTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MatchTopBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppBar(
      backgroundColor: c.backgroundPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title, style: AppStyles.title16Bold(context)),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: c.textPrimary),
          onPressed: () => AppFeedback.show(
            context,
            message: AiMatchStrings.comingSoon,
            type: AppFeedbackType.info,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 16),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: c.primary,
            child: Icon(Icons.person_rounded, size: 16, color: c.onPrimary),
          ),
        ),
      ],
    );
  }
}

/// White card, with an optional icon + title row on top.
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    this.borderColor,
    this.background,
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final Color? borderColor;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background ?? c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: iconColor ?? c.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(
                    child: Text(title!, style: AppStyles.title15Bold(context))),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

/// Small rounded label (AI MATCH INSIGHT, Verified Match, Mentored...).
class MatchTag extends StatelessWidget {
  const MatchTag({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppStyles.caption10Bold(context, color: color)),
        ],
      ),
    );
  }
}

/// Tinted skill chip (complementary = blue, skills to develop = orange).
class MatchChip extends StatelessWidget {
  const MatchChip({
    super.key,
    required this.label,
    required this.accent,
    this.icon,
  });

  final String label;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact blue button ("Open Project", "Complete Profile").
class MatchSmallButton extends StatelessWidget {
  const MatchSmallButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: c.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.onPrimary,
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 15, color: c.onPrimary),
            ],
          ],
        ),
      ),
    );
  }
}