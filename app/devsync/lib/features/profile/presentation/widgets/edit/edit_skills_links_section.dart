import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_decoration.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:flutter/material.dart';

// Soft skills, project domains, and external links for Edit Profile.
class EditSkillsLinksSection extends StatelessWidget {
  const EditSkillsLinksSection({
    super.key,
    required this.profile,
    required this.portfolioController,
    required this.linkedinController,
  });

  final ProfileController profile;
  final TextEditingController portfolioController;
  final TextEditingController linkedinController;

  static const _softSkills = {
    'Adaptability': Icons.sync,
    'Communication': Icons.chat_bubble_outline,
    'Problem-solving': Icons.extension_outlined,
    'Leadership': Icons.emoji_objects_outlined,
    'Teamwork': Icons.groups_outlined,
    'Time Management': Icons.schedule,
  };

  static const _domains = {
    'Mobile Apps': Icons.smartphone,
    'Web Development': Icons.language,
    'AI/ML': Icons.auto_awesome,
    'UI/UX': Icons.draw_outlined,
    'Open Source': Icons.public,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(
          'Soft Skills',
          trailing:
              '${profile.softSkills.length} / ${ProfileController.maxSoftSkills}',
          icon: Icons.groups_outlined,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in _softSkills.entries)
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
        const ProfileSectionLabel(
          'Project Domains & Interests',
          icon: Icons.interests_outlined,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in _domains.entries)
              ProfileSelectChip(
                e.key,
                icon: e.value,
                selected: profile.domains.contains(e.key),
                onTap: () => profile.toggleDomain(e.key),
              ),
          ],
        ),
        const ProfileSectionLabel('Links', icon: Icons.link_rounded),
        const ProfileFieldLabel(
          'Portfolio / Personal Website',
          trailing: 'Optional',
        ),
        TextField(
          controller: portfolioController,
          keyboardType: TextInputType.url,
          style: AppStyles.inputText(context),
          onChanged: (v) => profile.setLinks(portfolioUrl: v),
          decoration: profileFieldDecoration(
            context,
            prefixIcon: Icon(Icons.public, size: 18, color: c.textSecondary),
            hintText: 'https://yourportfolio.dev',
          ),
        ),
        const SizedBox(height: 14),
        const ProfileFieldLabel('LinkedIn Profile', trailing: 'Required'),
        TextField(
          controller: linkedinController,
          keyboardType: TextInputType.url,
          style: AppStyles.inputText(context),
          onChanged: (v) => profile.setLinks(linkedinUrl: v),
          decoration: profileFieldDecoration(
            context,
            prefixIcon: Icon(Icons.link, size: 18, color: c.textSecondary),
            hintText: 'https://linkedin.com/in/username',
          ),
        ),
      ],
    );
  }
}
