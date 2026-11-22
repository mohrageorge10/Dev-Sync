import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_ui.dart';
import 'package:flutter/material.dart';

const String _bannerTitle = 'Complete your profile first';
const String _bannerBody =
    'We need a few more details to recommend projects that really fit you. '
    'Add your primary track and verified languages to unlock higher '
    'precision recommendations.';

/// Card (with a blue bar on the left) that asks the user to improve the
/// profile. [calibratedPercent] is the "68% Calibrated" tag (hidden when null).
class ProfileTipBanner extends StatelessWidget {
  const ProfileTipBanner({
    super.key,
    required this.onComplete,
    required this.onDismiss,
    this.calibratedPercent,
  });

  final VoidCallback onComplete;
  final VoidCallback onDismiss;
  final int? calibratedPercent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.subtle(c.primary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_fix_high_rounded,
                          size: 18, color: c.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(_bannerTitle,
                            style: AppStyles.title15Bold(context)),
                      ),
                    ),
                    if (calibratedPercent != null) ...[
                      const SizedBox(width: 8),
                      _CalibratedPill(percent: calibratedPercent!),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _bannerBody,
                  style:
                      AppStyles.body12Secondary(context).copyWith(height: 1.45),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    MatchSmallButton(
                      label: AiMatchStrings.completeProfile,
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: onComplete,
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onDismiss,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Text(
                          AiMatchStrings.dismiss,
                          style: AppStyles.body12SemiBold(context,
                              color: c.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Blue accent bar on the left edge.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: c.primary),
          ),
        ],
      ),
    );
  }
}

/// "68% Calibrated" round tag.
class _CalibratedPill extends StatelessWidget {
  const _CalibratedPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.subtle(c.primary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percent% Calibrated',
        style: AppStyles.caption10Bold(context, color: c.primary),
      ),
    );
  }
}
