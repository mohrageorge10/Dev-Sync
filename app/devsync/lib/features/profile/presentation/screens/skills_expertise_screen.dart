import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_footer.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_progress.dart';
import 'package:flutter/material.dart';

// Step 3 of profile setup: soft skills and project domains.
class SkillsExpertiseScreen extends StatelessWidget {
  const SkillsExpertiseScreen({super.key});

  static const soft = {
    'Adaptability': Icons.sync,
    'Communication': Icons.chat_bubble_outline,
    'Problem-solving': Icons.extension_outlined,
    'Leadership': Icons.emoji_objects_outlined,
    'Teamwork': Icons.groups_outlined,
    'Time Management': Icons.schedule,
  };

  static const domains = {
    'Mobile Apps': Icons.smartphone,
    'Web Development': Icons.language,
    'AI/ML': Icons.auto_awesome,
    'UI/UX': Icons.draw_outlined,
    'Open Source': Icons.public,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'Skills & Expertise',
      footer: ProfileStepFooter(
        blockedReason: profile.softBlockedReason,
        onContinue: () async {
          await profile.saveProfile();
          if (!context.mounted) return;
          Navigator.pushNamed(context, AppRoutes.profileProjects);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStepProgress(60),
          Text('How do you work best?', style: AppStyles.h28(context)),
          const SizedBox(height: 4),
          Text(
            'Collaborative projects succeed on communication and shared passions.',
            style: AppStyles.body14Secondary(context),
          ),
          const SizedBox(height: 14),
          ProfileCard(
            color: c.subtleBlueSurface,
            borderColor: Colors.transparent,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.backgroundPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.hub_outlined, color: c.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Synergy Engine',
                        style: AppStyles.body12Bold(context),
                      ),
                      Text(
                        'Matches adapt automatically to align work habits, async rhythms, and collective drive.',
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ProfileSectionLabel(
            'Soft Skills & Collaboration Style',
            trailing:
                '${profile.softSkills.length} / ${ProfileController.maxSoftSkills}',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in soft.entries)
                ProfileSelectChip(
                  e.key,
                  icon: e.value,
                  selected: profile.softSkills.contains(e.key),
                  onTap: () {
                    if (!profile.toggleSoft(e.key)) {
                      AppFeedback.show(
                        context,
                        message: 'You can pick up to 4 core strengths.',
                        type: AppFeedbackType.warning,
                      );
                    }
                  },
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Select up to 4 core strengths that define your teamwork.',
              style: AppStyles.body11Secondary(context),
            ),
          ),
          const ProfileSectionLabel('Project Domains & Interests'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in domains.entries)
                ProfileSelectChip(
                  e.key,
                  icon: e.value,
                  selected: profile.domains.contains(e.key),
                  onTap: () => profile.toggleDomain(e.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
