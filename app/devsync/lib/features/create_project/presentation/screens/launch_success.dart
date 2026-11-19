import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 4: Project published confirmation screen.
class LaunchSuccessScreen extends StatelessWidget {
  const LaunchSuccessScreen({super.key, this.onDone, this.embedded = false});

  final VoidCallback? onDone;
  final bool embedded;

  void _finish(BuildContext context) {
    if (onDone != null) return onDone!();
    final reset = projectFlowResetter(context);
    Navigator.of(context).maybePop();
    reset();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final publishState = context.watch<PublishCubit>().state;
    final draft = context.watch<DraftCubit>().state.draft;
    final totalSize = 1 + context.watch<TeamCubit>().state.totalPeople;

    if (publishState is! PublishSuccess) return const SizedBox.shrink();
    final result = publishState.result;

    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Close button.
            Align(
              alignment: Alignment.centerRight,
              child: IconButton.filledTonal(
                onPressed: () => _finish(context),
                icon: const Icon(Icons.close),
              ),
            ),
            const Spacer(),

            // Animated rocket icon.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(Icons.rocket_launch, size: 68, color: c.primary),
              ),
            ),
            const SizedBox(height: 20),

            // Title and subtitle.
            Text('Your project is live!', style: AppStyles.h2(context)),
            const SizedBox(height: 6),
            Text(
              '${draft.title} is now published (${draft.purpose.label} · 1/$totalSize members filled).',
              textAlign: TextAlign.center,
              style: AppStyles.body12Secondary(context),
            ),
            const SizedBox(height: 20),

            // Matching developers card.
            if (result.urgentTrackName != null)
              SoftCard(
                child: Row(
                  children: [
                    Icon(Icons.person_search_outlined, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result.urgentTrackName} role is open for applications',
                            style: AppStyles.body12Bold(context),
                          ),
                          Text(
                            '${result.matchedDevelopers} registered developers match'
                            '${result.expertise.isEmpty ? '' : ' with ${result.expertise.join(' & ')} expertise'}.',
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),

            // Action buttons.
            AppPrimaryButton(
              buttonText: 'Done & Return',
              isDisabled: false,
              onPressed: () => _finish(context),
            ),
            const SizedBox(height: 8),
            AppSecondaryButton(
              buttonText: 'Create Another Project',
              onPressed: () => projectFlowResetter(context)(),
            ),
          ],
        ),
      ),
    );

    return embedded ? body : PopScope(canPop: false, child: Scaffold(body: body));
  }
}
