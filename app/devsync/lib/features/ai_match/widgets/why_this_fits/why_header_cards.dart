import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/widgets/match_score_ring.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';

// Top insight bar, project header card, and recommendation strength card.
class WhyHeaderSection extends StatelessWidget {
  const WhyHeaderSection({
    super.key,
    required this.match,
    required this.isSaved,
    required this.onToggleSave,
    required this.onShare,
  });

  final MatchModel match;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;

  String get _confidence => switch (match.fit) {
    MatchFit.strong => 'High Confidence',
    MatchFit.good => 'Medium Confidence',
    MatchFit.partial => 'Low Confidence',
  };

  String _shortTimeAgo(DateTime? date) {
    if (date == null) return '';
    final d = DateTime.now().difference(date);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 30) return '${d.inDays}d ago';
    return '${(d.inDays / 30).floor()}mo ago';
  }

  InlineSpan _maintainerSpan(BuildContext context) {
    final c = context.colors;
    final m = match.leadMaintainer;
    final i = m.indexOf(' (');
    final name = i == -1 ? m : m.substring(0, i);
    final handle = i == -1 ? '' : m.substring(i);
    return TextSpan(
      children: [
        const TextSpan(text: 'Lead Maintainer: '),
        TextSpan(
          text: name,
          style: AppStyles.body11Bold(context, color: c.textPrimary),
        ),
        if (handle.isNotEmpty) TextSpan(text: handle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isStrong = match.fit == MatchFit.strong;
    final fitColor = isStrong ? c.primary : matchFitColor(context, match.fit);
    final ringFit = isStrong ? MatchFit.good : match.fit;
    final isReal = match.purpose == ProjectPurpose.real;
    final purposeColor = isReal ? c.primary : c.success;
    final timeAgo = _shortTimeAgo(match.createdAt);
    final summary = match.matchedSkills.isEmpty
        ? ''
        : 'Your proficiency in ${match.matchedSkills.take(3).join(', ')} '
            'matches what this project needs.';

    return Column(
      children: [
        // Tag row: AI MATCH INSIGHT • Sprint ...... [bookmark][share]
        Row(
          children: [
            MatchTag(
              label: 'AI MATCH INSIGHT',
              color: c.primary,
              background: c.subtle(c.primary),
            ),
            if (match.sprintLabel.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.sprintLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.body11Secondary(context),
                ),
              ),
              const SizedBox(width: 8),
            ] else
              const Spacer(),
            _SquareIconButton(
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              active: isSaved,
              onTap: onToggleSave,
            ),
            const SizedBox(width: 6),
            _SquareIconButton(icon: Icons.share_outlined, onTap: onShare),
          ],
        ),
        const SizedBox(height: 12),

        // Project header card.
        MatchCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Icon(Icons.eco_rounded, size: 30, color: c.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: MatchTag(
                              label: isReal
                                  ? 'Real-world Project'
                                  : 'Learning Project',
                              color: purposeColor,
                              background: c.subtle(purposeColor),
                            ),
                          ),
                        ),
                        if (timeAgo.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: c.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      match.projectTitle,
                      style: AppStyles.title16Bold(context),
                    ),
                    if (match.leadMaintainer.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text.rich(
                        _maintainerSpan(context),
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Recommendation strength card.
        MatchCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'RECOMMENDATION STRENGTH',
                      style: AppStyles.overline9Bold(
                        context,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  MatchTag(
                    label: 'Verified Match',
                    color: c.primary,
                    background: c.subtle(c.primary),
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    MatchScoreRing(score: match.score, fit: ringFit, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: match.fitLabel,
                                  style: AppStyles.title15Bold(
                                    context,
                                    color: fitColor,
                                  ),
                                ),
                                TextSpan(
                                  text: '  •  $_confidence',
                                  style: AppStyles.body12Secondary(context),
                                ),
                              ],
                            ),
                          ),
                          if (summary.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.body12Secondary(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (match.explanation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.person_pin_circle_outlined,
                        size: 18,
                        color: c.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.explanation,
                          style: AppStyles.body12Primary(
                            context,
                          ).copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: active ? c.subtle(c.primary) : c.backgroundPrimary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? c.primary : c.border),
          ),
          child: Icon(
            icon,
            size: 16,
            color: active ? c.primary : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
