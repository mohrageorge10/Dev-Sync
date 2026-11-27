import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/my_application_model.dart';
import '../app_button.dart';
import '../section_card.dart';
import '../status_chip.dart';

// Card displaying an outgoing project application with live Pending/Accepted/Declined status.
class AppliedProjectCard extends StatelessWidget {
  const AppliedProjectCard({
    super.key,
    required this.application,
    this.onWithdraw,
    this.onOpenWorkspace,
  });

  final MyApplicationModel application;
  final VoidCallback? onWithdraw;
  final VoidCallback? onOpenWorkspace;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return '${(d.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (label, color, bg) = switch (application.status) {
      ApplicationStatus.pending => (
        'Pending',
        c.warning,
        c.subtle(c.warning),
      ),
      ApplicationStatus.accepted => (
        'Accepted',
        c.success,
        c.subtle(c.success),
      ),
      ApplicationStatus.declined => (
        'Declined',
        c.error,
        c.subtle(c.error),
      ),
    };
    final ago = _timeAgo(application.createdAt);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.projectTitle,
                  style: AppStyles.title15Bold(context),
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(label: label, color: color, background: bg),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.work_outline_rounded, size: 14, color: c.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Applied track: ${application.track}',
                  style: AppStyles.body12Secondary(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (ago.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(ago, style: AppStyles.caption10Secondary(context)),
              ],
            ],
          ),
          if (application.status == ApplicationStatus.pending &&
              onWithdraw != null) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Withdraw Application',
              outlined: true,
              color: c.error,
              onPressed: onWithdraw!,
            ),
          ] else if (application.status == ApplicationStatus.accepted &&
              onOpenWorkspace != null) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Open Team Workspace',
              onPressed: onOpenWorkspace!,
            ),
          ] else if (application.status == ApplicationStatus.declined) ...[
            const SizedBox(height: 8),
            Text(
              'This application was declined by the project owner.',
              style: AppStyles.body11Secondary(context),
            ),
          ],
        ],
      ),
    );
  }
}
