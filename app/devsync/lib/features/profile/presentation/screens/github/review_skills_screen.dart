import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/screens/github/disconnect_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/github/detected_skill_card.dart';
import 'package:devsync/features/profile/presentation/widgets/github/github_summary_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';

// Screen for approving or dismissing skills detected from GitHub activity.
class ReviewSkillsScreen extends StatelessWidget {
  const ReviewSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);
    final analysis = profile.analysis;

    if (analysis == null) {
      return ProfileScaffold(
        title: 'Review Detected Skills',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Column(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 48, color: c.primary),
              const SizedBox(height: 14),
              Text(
                'No GitHub analysis loaded yet',
                style: AppStyles.title16Bold(context),
              ),
              const SizedBox(height: 6),
              Text(
                'Run a quick sync to inspect your public repositories and skill suggestions.',
                textAlign: TextAlign.center,
                style: AppStyles.body13Secondary(context),
              ),
              const SizedBox(height: 20),
              ProfilePrimaryButton(
                'Analyze GitHub Now',
                icon: Icons.refresh_rounded,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.profileGithubAnalysis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final existing = {
      ...profile.languages.keys,
      ...profile.frameworks,
    }.map((e) => e.trim().toLowerCase()).toSet();

    final visible = analysis.skills
        .where(
          (s) =>
              s.status != SkillStatus.dismissed &&
              (s.status == SkillStatus.added ||
                  !existing.contains(s.name.trim().toLowerCase())),
        )
        .toList();

    return ProfileScaffold(
      title: 'Review Detected Skills',
      actions: [
        IconButton(
          tooltip: 'Disconnect GitHub',
          icon: Icon(Icons.link_off, size: 20, color: c.error),
          onPressed: () async {
            final ok = await showDisconnectGithubDialog(
              context,
              keptSkills: profile.addedCount,
            );
            if (ok && context.mounted) {
              profile.disconnectGithub();
              await profile.saveProfile();
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfilePrimaryButton(
            'Save Selected Skills (${profile.addedCount} added)',
            icon: Icons.save_outlined,
            onPressed: () async {
              await profile.saveProfile();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          AppTextButton(
            onPressed: () => Navigator.pop(context),
            buttonText: 'Manage in Profile Settings ›',
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome, color: c.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skills we detected', style: AppStyles.h20(context)),
                    Text(
                      "These are suggestions based on your activity. Add only what's accurate.",
                      style: AppStyles.body12Secondary(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProfileCard(
            color: c.subtleBlueSurface,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 14, color: c.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Suggestions • Never added without your approval',
                    style: AppStyles.body11SemiBold(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GithubSummaryCard(analysis: analysis),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Detected Skill Suggestions',
                style: AppStyles.body13Bold(context),
              ),
              const SizedBox(width: 6),
              ProfileTag('${analysis.skills.length} total'),
              const Spacer(),
              if (profile.pendingSuggestions.isNotEmpty)
                GestureDetector(
                  onTap: profile.addAllDetected,
                  child: Text(
                    'Add all',
                    style: AppStyles.body12Bold(context, color: c.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final s in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DetectedSkillCard(skill: s, profile: profile),
            ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No more suggestions.',
                  style: AppStyles.body13Secondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
