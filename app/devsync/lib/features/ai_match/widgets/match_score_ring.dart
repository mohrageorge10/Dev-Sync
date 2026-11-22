import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:flutter/material.dart';

/// Color that represents how strong the match is.
Color matchFitColor(BuildContext context, MatchFit fit) {
  final c = context.colors;
  return switch (fit) {
    MatchFit.strong => c.success,
    MatchFit.good => c.primary,
    MatchFit.partial => c.warning,
  };
}

/// Circular progress with the match percent in the middle.
class MatchScoreRing extends StatelessWidget {
  const MatchScoreRing({
    super.key,
    required this.score,
    required this.fit,
    this.size = 64,
  });

  final int score;
  final MatchFit fit;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: c.border,
              color: matchFitColor(context, fit),
            ),
          ),
          Text('$score%', style: AppStyles.title15Bold(context)),
        ],
      ),
    );
  }
}
