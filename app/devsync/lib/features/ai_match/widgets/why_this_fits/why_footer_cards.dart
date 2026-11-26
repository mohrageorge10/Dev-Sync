import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_actions_ui.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';

const List<IconData> _learnIcons = [
  Icons.bluetooth_rounded,
  Icons.storage_rounded,
  Icons.hub_outlined,
];

// Card listing key things the developer can learn by contributing.
class WhyLearningCard extends StatelessWidget {
  const WhyLearningCard({super.key, required this.points});

  final List<String> points;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MatchCard(
      title: 'What you could learn',
      icon: Icons.auto_awesome_outlined,
      iconColor: c.primary,
      child: Column(
        children: [
          for (var i = 0; i < points.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == points.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _learnIcons[i % _learnIcons.length],
                    size: 18,
                    color: c.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      points[i],
                      style: AppStyles.body12Primary(context).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Inline thumbs-up / thumbs-down feedback card for the match recommendation.
class WhyRateCard extends StatelessWidget {
  const WhyRateCard({
    super.key,
    required this.rated,
    required this.onRate,
  });

  final bool? rated;
  final void Function({bool? helpful}) onRate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MatchCard(
      child: Row(
        children: [
          Icon(Icons.thumbs_up_down_outlined, size: 18, color: c.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AiMatchStrings.helpfulQuestion,
              style: AppStyles.body12SemiBold(context),
            ),
          ),
          _ThumbButton(
            icon: rated == true
                ? Icons.thumb_up_alt_rounded
                : Icons.thumb_up_alt_outlined,
            selected: rated == true,
            onTap: () => onRate(helpful: true),
          ),
          const SizedBox(width: 8),
          _ThumbButton(
            icon: rated == false
                ? Icons.thumb_down_alt_rounded
                : Icons.thumb_down_alt_outlined,
            selected: rated == false,
            onTap: () => onRate(helpful: false),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => onRate(),
            child: Text(
              'Rate',
              style: AppStyles.body12Bold(context, color: c.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky bottom action bar with View Skill Gap and Request to Join buttons.
class WhyBottomBar extends StatelessWidget {
  const WhyBottomBar({
    super.key,
    required this.actions,
    required this.onViewSkillGap,
    required this.onRequestJoin,
  });

  final MatchActionsState actions;
  final VoidCallback onViewSkillGap;
  final VoidCallback onRequestJoin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final join = joinButtonSpec(actions);

    return Container(
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: MatchActionButton(
                label: AiMatchStrings.viewSkillGap,
                leadingIcon: Icons.close_fullscreen_rounded,
                onTap: onViewSkillGap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MatchActionButton(
                label: join.label,
                leadingIcon: join.lead,
                trailingIcon: join.trail,
                filled: join.filled,
                enabled: join.enabled,
                loading: join.loading,
                onTap: onRequestJoin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbButton extends StatelessWidget {
  const _ThumbButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.subtle(c.primary) : c.backgroundPrimary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? c.subtle(c.primary) : c.border,
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: selected ? c.primary : c.textSecondary,
          ),
        ),
      ),
    );
  }
}
