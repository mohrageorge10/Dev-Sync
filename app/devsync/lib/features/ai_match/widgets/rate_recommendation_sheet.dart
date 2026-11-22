import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/ai_match/business_logic/match_feedback_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_feedback_state.dart';
import 'package:devsync/features/ai_match/data/models/match_feedback.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the "Rate Recommendation" bottom sheet.
/// Returns the rating (true = helpful) after it was sent, null if closed.
Future<bool?> showRateRecommendationSheet(
  BuildContext context, {
  required MatchModel match,
  bool? initialHelpful,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: context.colors.backgroundPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider<MatchFeedbackCubit>(
      create: (_) => ServiceLocator.get<MatchFeedbackCubit>(),
      child: RateRecommendationSheet(
        match: match,
        initialHelpful: initialHelpful,
      ),
    ),
  );
}

class RateRecommendationSheet extends StatefulWidget {
  const RateRecommendationSheet({
    super.key,
    required this.match,
    this.initialHelpful,
  });

  final MatchModel match;
  final bool? initialHelpful;

  @override
  State<RateRecommendationSheet> createState() =>
      _RateRecommendationSheetState();
}

class _RateRecommendationSheetState extends State<RateRecommendationSheet> {
  final _comment = TextEditingController();
  final Set<String> _reasons = {};
  bool? _helpful;
  int _clarity = 0;

  @override
  void initState() {
    super.initState();
    _helpful = widget.initialHelpful;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    final helpful = _helpful;
    if (helpful == null) return;
    context.read<MatchFeedbackCubit>().submit(
          MatchFeedback(
            projectId: widget.match.projectId,
            helpful: helpful,
            clarity: _clarity,
            reasons: helpful ? const [] : _reasons.toList(),
            comment: _comment.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocConsumer<MatchFeedbackCubit, MatchFeedbackState>(
      listener: (context, state) {
        if (state is MatchFeedbackSuccess) {
          AppFeedback.show(
            context,
            message: AiMatchStrings.feedbackThanks,
            type: AppFeedbackType.success,
          );
          Navigator.pop(context, _helpful);
        } else if (state is MatchFeedbackError) {
          AppFeedback.show(
            context,
            message: state.message,
            type: AppFeedbackType.error,
          );
        }
      },
      builder: (context, state) {
        final submitting = state is MatchFeedbackSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header: small title + close
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AiMatchStrings.rateTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question + subtitle
                Text(
                  AiMatchStrings.rateQuestion,
                  style: TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AiMatchStrings.rateSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Helpful / Not a good fit
                Row(
                  children: [
                    Expanded(
                      child: _VoteButton(
                        label: AiMatchStrings.helpful,
                        icon: Icons.thumb_up_alt_outlined,
                        selected: _helpful == true,
                        onTap: () => setState(() => _helpful = true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VoteButton(
                        label: AiMatchStrings.notGoodFit,
                        icon: Icons.thumb_down_alt_outlined,
                        selected: _helpful == false,
                        onTap: () => setState(() => _helpful = false),
                      ),
                    ),
                  ],
                ),

                // Reasons (only when the match was not good)
                if (_helpful == false) ...[
                  const SizedBox(height: 20),
                  Text(
                    AiMatchStrings.whatWasWrong,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in AiMatchStrings.wrongReasons)
                        AppSkillChip(
                          label: r,
                          selected: _reasons.contains(r),
                          onTap: () => setState(() {
                            if (!_reasons.add(r)) _reasons.remove(r);
                          }),
                        ),
                    ],
                  ),
                ],

                // Clarity stars
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AiMatchStrings.clarityQuestion,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    if (_clarity > 0)
                      Text(
                        '$_clarity / 5',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => _clarity = i),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            i <= _clarity
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 32,
                            color: i <= _clarity ? c.primary : c.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_clarity > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    AiMatchStrings.clarityLabels[_clarity - 1],
                    style: TextStyle(fontSize: 12, color: c.textSecondary),
                  ),
                ],

                // Additional thoughts
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    text: AiMatchStrings.additionalThoughts,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: ' ${AiMatchStrings.optional}',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AppInputField(
                  controller: _comment,
                  hint: AiMatchStrings.additionalHint,
                  minLines: 3,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                ),

                // Submit + cancel
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    buttonText: AiMatchStrings.submitFeedback,
                    isDisabled: _helpful == null || submitting,
                    onPressed: _submit,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AiMatchStrings.cancel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Helpful" / "Not a good fit" button (outlined; blue tint when selected).
class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.primary : c.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? c.subtleBlueSurface : c.backgroundPrimary,
          border: Border.all(color: selected ? c.primary : c.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
