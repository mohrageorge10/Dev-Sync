import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/auth/screens/login_required_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Shows the one-time message of [MatchActionsState.event]
/// (snack bar, or the login sheet when the user is signed out).
void handleMatchActionEvent(BuildContext context, MatchActionEvent e) {
  switch (e.kind) {
    case MatchActionEventKind.needsLogin:
      showLoginRequiredSheet(context);
    case MatchActionEventKind.saved:
    case MatchActionEventKind.unsaved:
    case MatchActionEventKind.requestSent:
      AppFeedback.show(context,
          message: e.message, type: AppFeedbackType.success);
    case MatchActionEventKind.error:
      AppFeedback.show(context,
          message: e.message, type: AppFeedbackType.error);
  }
}

/// How the "Request to Join" button looks for the current state.
typedef JoinButtonSpec = ({
  String label,
  IconData? lead,
  IconData? trail,
  bool filled,
  bool enabled,
  bool loading,
});

JoinButtonSpec joinButtonSpec(MatchActionsState s) {
  if (s.sendingRequest) {
    return (
      label: AiMatchStrings.requestSending,
      lead: null,
      trail: null,
      filled: true,
      enabled: false,
      loading: true,
    );
  }
  return switch (s.request) {
    null => (
        label: AiMatchStrings.requestToJoin,
        lead: null,
        trail: Icons.arrow_forward_rounded,
        filled: true,
        enabled: true,
        loading: false,
      ),
    RequestStatus.pending => (
        label: AiMatchStrings.requestSent,
        lead: Icons.check_rounded,
        trail: null,
        filled: false,
        enabled: false,
        loading: false,
      ),
    RequestStatus.accepted => (
        label: AiMatchStrings.requestAccepted,
        lead: Icons.check_circle_outline_rounded,
        trail: null,
        filled: false,
        enabled: false,
        loading: false,
      ),
    RequestStatus.rejected => (
        label: AiMatchStrings.requestDeclined,
        lead: Icons.block_rounded,
        trail: null,
        filled: false,
        enabled: false,
        loading: false,
      ),
  };
}

/// Full-width 48px button: [filled] = solid blue, otherwise soft blue.
/// [enabled] = false greys it out, [loading] shows a small spinner.
class MatchActionButton extends StatelessWidget {
  const MatchActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
    this.enabled = true,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool enabled;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final Color fg;
    final Color bg;
    if (filled) {
      fg = c.onPrimary;
      bg = enabled ? c.primary : c.primary.withValues(alpha: 0.6);
    } else {
      fg = enabled ? c.textPrimary : c.textSecondary;
      bg = c.subtleBlueSurface;
    }
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
              const SizedBox(width: 8),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 17, color: fg),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
            if (!loading && trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 17, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
