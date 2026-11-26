import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_select_chip.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/custom_tag_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/language_proficiency_card.dart';
import 'package:devsync/features/profile/presentation/widgets/technical/track_options.dart';
import 'package:flutter/material.dart';

// Technical track, level, languages, and stack editor for Edit Profile.
class EditTechnicalSection extends StatelessWidget {
  const EditTechnicalSection({super.key, required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tracks = trackSpecializations.keys.toList();
    final subTracks = profile.track != null
        ? (trackSpecializations[profile.track!] ?? const <String>[])
        : const <String>[];
    final allLanguages = {
      ...defaultProgrammingLanguages,
      ...profile.customLanguages,
      ...profile.languages.keys,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionLabel(
          'Main Track',
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
          'Other Tracks',
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
          icon: Icons.code_rounded,
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
      ],
    );
  }
}
