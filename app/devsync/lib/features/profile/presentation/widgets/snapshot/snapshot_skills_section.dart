import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';

// Displays categorized user skills inside a structured card plus AI suggestions.
class SnapshotSkillsSection extends StatelessWidget {
  const SnapshotSkillsSection({super.key, required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final suggestions = profile.pendingSuggestions;
    final isVerified =
        profile.verifiedSkills.isNotEmpty || profile.githubConnected;
    final extraVerified = profile.verifiedSkills
        .where(
          (s) =>
              !profile.languages.containsKey(s) &&
              !profile.frameworks.contains(s),
        )
        .toList();

    final groups = <Widget>[
      if (profile.secondaryTracks.isNotEmpty)
        _SkillGroup(
          label: 'OTHER TRACKS',
          icon: Icons.workspaces_outline,
          children: [
            for (final track in profile.secondaryTracks)
              _SkillPill(
                label: track,
                backgroundColor: c.subtleBlueSurface,
                borderColor: c.primary.withValues(alpha: 0.25),
                textColor: c.primary,
                bold: true,
              ),
          ],
        ),
      if (profile.languages.isNotEmpty)
        _SkillGroup(
          label: 'PROGRAMMING LANGUAGES',
          icon: Icons.terminal_rounded,
          children: [
            for (final lang in profile.languages.keys)
              _SkillPill(
                label: lang,
                backgroundColor: c.subtleBlueSurface,
                borderColor: c.border,
                textColor: c.textPrimary,
                bold: true,
              ),
          ],
        ),
      if (profile.frameworks.isNotEmpty)
        _SkillGroup(
          label: 'TECHNICAL STACK & TOOLS',
          icon: Icons.layers_outlined,
          children: [
            for (final tool in profile.frameworks)
              _SkillPill(
                label: tool,
                backgroundColor: c.surface,
                borderColor: c.border,
                textColor: c.textPrimary,
              ),
          ],
        ),
      if (profile.softSkills.isNotEmpty)
        _SkillGroup(
          label: 'COLLABORATION & SOFT SKILLS',
          icon: Icons.groups_outlined,
          children: [
            for (final skill in profile.softSkills)
              _SkillPill(
                label: skill,
                backgroundColor: c.backgroundPrimary,
                borderColor: c.border,
                textColor: c.textSecondary,
              ),
          ],
        ),
      if (extraVerified.isNotEmpty)
        _SkillGroup(
          label: 'VERIFIED FROM GITHUB',
          icon: Icons.verified_outlined,
          children: [
            for (final skill in extraVerified)
              _SkillPill(
                label: skill,
                icon: Icons.verified_rounded,
                backgroundColor: c.subtle(c.success),
                borderColor: c.success.withValues(alpha: 0.25),
                textColor: c.success,
                bold: true,
              ),
          ],
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 10),
          child: Row(
            children: [
              Icon(Icons.code_rounded, size: 17, color: c.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Skills',
                  style: AppStyles.body14Bold(context),
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.subtleBlueSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 13, color: c.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: AppStyles.body11Bold(context, color: c.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        ProfileCard(
          padding: const EdgeInsets.all(14),
          child: groups.isEmpty
              ? Text(
                  'No skills added yet. Tap the edit button to add your stack.',
                  style: AppStyles.body12Secondary(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < groups.length; i++) ...[
                      if (i > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: c.border),
                        ),
                      groups[i],
                    ],
                  ],
                ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 14),
          ProfileCard(
            color: c.subtleBlueSurface,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 15, color: c.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AI-Detected Skills',
                        style: AppStyles.body12Bold(context),
                      ),
                    ),
                    ProfileTag('${suggestions.length} Suggestions'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Inferred from your activity. Accept to add them to your profile or dismiss.',
                  style: AppStyles.caption10Secondary(context),
                ),
                const SizedBox(height: 8),
                for (final s in suggestions)
                  _SuggestionRow(skill: s, profile: profile),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup({
    required this.label,
    required this.icon,
    required this.children,
  });

  final String label;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: c.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppStyles.overline9Secondary(context, letterSpacing: 0.6),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: children),
      ],
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.icon,
    this.bold = false,
  }) : sublabel = null;

  final String label;
  final String? sublabel;
  final IconData? icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: bold
                ? AppStyles.body12SemiBold(context, color: textColor)
                : AppStyles.body12Medium(context, color: textColor),
          ),
          if (sublabel != null && sublabel!.isNotEmpty) ...[
            Text(' · ', style: AppStyles.body11Secondary(context)),
            Text(sublabel!, style: AppStyles.body11Secondary(context)),
          ],
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.skill, required this.profile});

  final DetectedSkill skill;
  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: c.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.name, style: AppStyles.body12Bold(context)),
                Text(
                  'Confidence: ${skill.confidence}',
                  style: AppStyles.caption10Secondary(context),
                ),
              ],
            ),
          ),
          _CircleIconButton(Icons.check, c.primary, () async {
            profile.addDetected(skill);
            await profile.saveProfile();
          }),
          const SizedBox(width: 6),
          _CircleIconButton(
            Icons.close,
            c.textSecondary,
            () => profile.dismissDetected(skill),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton(this.icon, this.color, this.onTap);

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
