import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/presentation/cubit/insights/insights_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Live project strength progress bar and next tip.
class ProjectStrengthMeter extends StatelessWidget {
  const ProjectStrengthMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final insights = context.watch<InsightsCubit>().state;
    final score = insights.strength;
    final color =
        score >= 80 ? c.success : (score >= 50 ? c.primary : c.warning);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Project strength', style: AppStyles.body12Bold(context)),
              const Spacer(),
              Text(
                '${insights.label} · $score%',
                style: AppStyles.body12Bold(context, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 350),
            builder: (_, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                color: color,
                backgroundColor: c.secondarySurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(insights.tip, style: AppStyles.body11Secondary(context)),
        ],
      ),
    );
  }
}
