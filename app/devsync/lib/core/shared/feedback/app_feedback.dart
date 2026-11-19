import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

enum AppFeedbackType { info, success, warning, error }

// Unified top and bottom toast notifications.
class AppFeedback {
  AppFeedback._();

  static OverlayEntry? _topEntry;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppFeedbackType type = AppFeedbackType.info,
    bool fromTop = false,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final c = context.colors;
    final accent = switch (type) {
      AppFeedbackType.success => c.success,
      AppFeedbackType.warning => c.warning,
      AppFeedbackType.error => c.error,
      AppFeedbackType.info => c.primary,
    };
    final icon = switch (type) {
      AppFeedbackType.success => Icons.check_circle_rounded,
      AppFeedbackType.warning => Icons.warning_amber_rounded,
      AppFeedbackType.error => Icons.error_outline_rounded,
      AppFeedbackType.info => Icons.info_outline_rounded,
    };

    if (fromTop) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) {
        _topEntry?.remove();
        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (_) => _TopToast(
            duration: duration,
            onDismiss: () {
              if (_topEntry == entry) {
                entry.remove();
                _topEntry = null;
              }
            },
            child: _FeedbackCard(
              title: title,
              message: message,
              icon: icon,
              accent: accent,
              actionLabel: actionLabel,
              onAction: onAction == null
                  ? null
                  : () {
                      onAction();
                      if (_topEntry == entry) {
                        entry.remove();
                        _topEntry = null;
                      }
                    },
            ),
          ),
        );
        _topEntry = entry;
        overlay.insert(entry);
        return;
      }
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: EdgeInsets.zero,
        content: _FeedbackCard(
          title: title,
          message: message,
          icon: icon,
          accent: accent,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
        ),
      ),
    );
  }
}

// Styled feedback card.
class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.message,
    required this.icon,
    required this.accent,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  final String? title, actionLabel;
  final String message;
  final IconData icon;
  final Color accent;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.subtle(accent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null && title!.isNotEmpty)
                    Text(title!, style: AppStyles.body12Bold(context)),
                  Text(message, style: AppStyles.body12SemiBold(context)),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  backgroundColor: c.subtle(accent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppStyles.body11Bold(context, color: accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Animated top overlay wrapper.
class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.child,
    required this.duration,
    required this.onDismiss,
  });

  final Widget child;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _ctrl,
        child: GestureDetector(
          onVerticalDragEnd: (_) => widget.onDismiss(),
          child: widget.child,
        ),
      ),
    );
  }
}
