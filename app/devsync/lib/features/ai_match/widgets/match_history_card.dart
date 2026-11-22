import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_formatters.dart';
import 'package:devsync/features/ai_match/utils/ai_match_icons.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';

// How many skill tags fit in the card before the "+N" tag.
const int _maxSkillTags = 4;

/// One recommended project in the match history list.
class MatchHistoryCard extends StatelessWidget {
  const MatchHistoryCard({
    super.key,
    required this.match,
    required this.onOpenProject,
    required this.onWhy,
  });

  final MatchModel match;
  final VoidCallback onOpenProject;
  final VoidCallback onWhy;

  // "EcoTrack Mobile: Carbon Analytics" -> title + subtitle.
  // Without ":" the subtitle is the project description.
  (String, String) get _titleParts {
    final full = match.projectTitle;
    final i = full.indexOf(':');
    if (i > 0 && i < full.length - 1) {
      return (full.substring(0, i).trim(), full.substring(i + 1).trim());
    }
    return (full, match.projectDescription);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isReal = match.purpose == ProjectPurpose.real;
    final (title, subtitle) = _titleParts;
    final updated = timeAgo(match.createdAt);
    final skills = match.matchedSkills;
    final extra = skills.length - _maxSkillTags;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project + purpose
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.subtle(c.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  projectIconFor(match.projectTitle, match.projectDescription),
                  size: 22,
                  color: c.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.title16Bold(context)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.body12Secondary(context)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Real-world = blue, Learning = neutral grey.
              MatchTag(
                label: isReal ? 'Real-world' : 'Learning',
                color: isReal ? c.primary : c.textPrimary,
                background: isReal
                    ? c.subtle(c.primary)
                    : c.subtle(c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Score + time + short explanation, all in one blue box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 16, color: c.primary),
                    const SizedBox(width: 6),
                    Text('${match.score}% Match Score',
                        style: AppStyles.body12Bold(context, color: c.primary)),
                    if (updated.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '•  Matched ${updated == 'Just now' ? 'just now' : updated}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.body11Secondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
                if (match.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    match.explanation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.body12Primary(context)
                        .copyWith(height: 1.4),
                  ),
                ],
              ],
            ),
          ),

          // Skills
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills.take(_maxSkillTags)) _SkillTag(label: s),
                if (extra > 0) _SkillTag(label: '+$extra'),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MatchSmallButton(
                label: AiMatchStrings.openProject,
                trailingIcon: Icons.north_east_rounded,
                onPressed: onOpenProject,
              ),
              GestureDetector(
                onTap: onWhy,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AiMatchStrings.whyItFits,
                          style: AppStyles.body12SemiBold(context,
                              color: c.primary)),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: c.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small grey skill tag used in the history card.
class _SkillTag extends StatelessWidget {
  const _SkillTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.subtle(c.textSecondary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
    );
  }
}
