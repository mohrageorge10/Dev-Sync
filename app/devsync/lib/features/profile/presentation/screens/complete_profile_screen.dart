import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/complete/completion_progress_card.dart';
import 'package:devsync/features/profile/presentation/widgets/complete/completion_status_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';

// Profile completion checklist and verification progress overview.
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  static const _targets = {
    'Basic Info': AppRoutes.profileBasicInfo,
    'Track & Experience Level': AppRoutes.profileTechnical,
    'Languages & Frameworks': AppRoutes.profileTechnical,
    'Soft Skills & Interests': AppRoutes.profileSkills,
    'CV': AppRoutes.profileProjects,
    'Portfolio Link': AppRoutes.profileProjects,
    'LinkedIn Link': AppRoutes.profileProjects,
    'GitHub Connection': AppRoutes.profileGithubConnect,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);
    final items = profile.checklist;
    final done = profile.completion == 100;
    final missing = items.length - profile.completedItems;

    return ProfileScaffold(
      title: 'Complete your profile',
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, size: 20, color: c.textSecondary),
          onPressed: () => _showHelp(context),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CompletionProgressCard(
            completion: profile.completion,
            missingCount: missing,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Verification Checklist',
                style: AppStyles.body13Bold(context),
              ),
              const SizedBox(width: 8),
              ProfileTag('${profile.completedItems} of ${items.length}'),
              const Spacer(),
              Text(
                '${profile.completion}% READY',
                style: AppStyles.overline9Bold(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProfileCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.surface),
                  ChecklistItemRow(
                    item: items[i],
                    onAdd: () =>
                        Navigator.pushNamed(context, _targets[items[i].title]!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          CompletionStatusCard(
            completion: profile.completion,
            missingCount: missing,
            onCompleteNext: () {
              final first = items.firstWhere((e) => !e.done).title;
              Navigator.pushNamed(context, _targets[first]!);
            },
          ),
          if (!done) ...[
            const SizedBox(height: 12),
            Center(
              child: AppTextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.profileSnapshot),
                buttonText: 'View my profile',
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Why complete your profile?',
          style: AppStyles.h20(dialogCtx),
        ),
        content: Text(
          'Each completed item gives the matching engine more evidence about your skills, so you get more accurate project and team recommendations.',
          style: AppStyles.body14Secondary(dialogCtx),
        ),
        actions: [
          AppTextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            buttonText: 'Got it',
          ),
        ],
      ),
    );
  }
}
