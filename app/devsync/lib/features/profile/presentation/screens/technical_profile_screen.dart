import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_footer.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_progress.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/custom_tag_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/language_proficiency_card.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/track_options.dart';
import 'package:flutter/material.dart';

// Step 2 of profile setup: track, specialization, level, languages, and stack.
class TechnicalProfileScreen extends StatelessWidget {
  const TechnicalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);
    final tracks = trackSpecializations.keys.toList();
    final subTracks = profile.track != null
        ? (trackSpecializations[profile.track!] ?? const <String>[])
        : const <String>[];
    final allLanguages = {
      ...defaultProgrammingLanguages,
      ...profile.customLanguages,
      ...profile.languages.keys,
    };

    return ProfileScaffold(
      title: 'Technical Profile',
      footer: ProfileStepFooter(
        blockedReason: profile.technicalBlockedReason,
        onContinue: () async {
          await profile.saveProfile();
          if (!context.mounted) return;
          Navigator.pushNamed(context, AppRoutes.profileSkills);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStepProgress(40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "What's your technical profile?",
                  style: AppStyles.h1(context),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: c.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.code, size: 15, color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Select your primary engineering discipline, specialization, experience level, and core toolset.',
            style: AppStyles.body13Secondary(context),
          ),
          ProfileSectionLabel(
            'Main Engineering Track',
            trailing: 'Single select',
            trailingColor: c.textSecondary,
            icon: Icons.layers_outlined,
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
            children: [
              for (final t in tracks)
                ProfileSelectChip(
                  t,
                  pill: false,
                  showCheck: false,
                  selected: profile.track == t,
                  expand: true,
                  onTap: () => profile.setTrack(t),
                ),
            ],
          ),
          if (subTracks.isNotEmpty) ...[
            ProfileSectionLabel(
              '${profile.track} Specialization',
              trailing: 'Optional',
              trailingColor: c.textSecondary,
              icon: Icons.tune_rounded,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                for (final sub in subTracks)
                  ProfileSelectChip(
                    sub,
                    selected: profile.subTrack == sub,
                    onTap: () => profile.setSubTrack(sub),
                  ),
              ],
            ),
          ],
          ProfileSectionLabel(
            'Other Tracks You Know',
            trailing: profile.secondaryTracks.isEmpty
                ? 'Optional'
                : '${profile.secondaryTracks.length} selected',
            trailingColor: profile.secondaryTracks.isEmpty
                ? c.textSecondary
                : c.primary,
            icon: Icons.workspaces_outline,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final t in tracks.where((t) => t != profile.track))
                ProfileSelectChip(
                  t,
                  selected: profile.secondaryTracks.contains(t),
                  onTap: () => profile.toggleSecondaryTrack(t),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Open projects needing any of these tracks will also be available for you to apply.',
              style: AppStyles.body11Secondary(context),
            ),
          ),
          const ProfileSectionLabel('Experience Level', icon: Icons.trending_up),
          ProfileSegmentedBar(
            items: ProfileController.levels,
            selected: profile.level,
            onChanged: profile.setLevel,
          ),
          ProfileSectionLabel(
            'Programming Languages',
            trailing: '${profile.languages.length} selected',
            icon: Icons.terminal,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final lang in allLanguages)
                ProfileSelectChip(
                  lang,
                  selected: profile.languages.containsKey(lang),
                  onTap: () => profile.toggleLanguage(lang),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextButton(
              onPressed: () => showCustomTagDialog(
                context,
                title: 'Add custom language',
                subtitle: 'Enter a programming language not listed above.',
                hintText: 'e.g. Rust, Ruby, Scala',
                onAdd: profile.addCustomLanguage,
              ),
              leadingIcon: Icons.add_circle_outline,
              buttonText: 'Add custom language',
            ),
          ),
          if (profile.languages.isNotEmpty) ...[
            const SizedBox(height: 14),
            LanguageProficiencyCard(profile: profile),
          ],
          const ProfileSectionLabel(
            'Frameworks & Technical Skills',
            icon: Icons.layers_outlined,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: [
              for (final f in {
                ...defaultFrameworks,
                ...profile.customSkills,
                ...profile.frameworks,
              })
                ProfileSelectChip(
                  f,
                  selected: profile.frameworks.contains(f),
                  onTap: () => profile.toggleFramework(f),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: AppTextButton(
              onPressed: () => showCustomTagDialog(
                context,
                title: 'Add custom skill',
                subtitle: 'Add a framework, library, or tool to your stack.',
                hintText: 'e.g. GraphQL, NestJS, Supabase',
                onAdd: profile.addCustomSkill,
              ),
              leadingIcon: Icons.add_circle_outline,
              buttonText: 'Add custom skill',
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            color: c.subtleBlueSurface,
            borderColor: Colors.transparent,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_awesome, color: c.onPrimary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Curated Match Preview',
                        style: AppStyles.body12Bold(context),
                      ),
                      Text(
                        profile.frameworks.isEmpty
                            ? 'Pick your stack to see matching teams.'
                            : 'Over 24 team projects currently looking for ${profile.frameworks.take(2).join(' + ')} contributors!',
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
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
