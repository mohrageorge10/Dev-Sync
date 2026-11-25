import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:flutter/material.dart';

// Card representing a single GitHub-detected skill with Add/Undo/Dismiss controls.
class DetectedSkillCard extends StatelessWidget {
  const DetectedSkillCard({
    super.key,
    required this.skill,
    required this.profile,
  });

  final DetectedSkill skill;
  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final added = skill.status == SkillStatus.added;
    final high = skill.confidence == 'High';

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(skill.name, style: AppStyles.body14Bold(context)),
              ),
              const SizedBox(width: 8),
              ProfileTag(
                '${skill.confidence} Confidence',
                fg: high ? c.primary : c.textSecondary,
                bg: high ? c.subtleBlueSurface : c.surface,
              ),
              const Spacer(),
              if (!added)
                InkWell(
                  onTap: () => profile.dismissDetected(skill),
                  child: Icon(Icons.close, size: 16, color: c.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(skill.evidence, style: AppStyles.body11Secondary(context)),
          const SizedBox(height: 10),
          if (added)
            Row(
              children: [
                ProfileTag(
                  '✓ Added to profile',
                  fg: c.primary,
                  bg: c.subtleBlueSurface,
                ),
                const Spacer(),
                AppTextButton(
                  onPressed: () => profile.undoDetected(skill),
                  buttonText: 'Undo',
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ProfilePrimaryButton(
                    'Add Skill',
                    icon: Icons.add,
                    onPressed: () => profile.addDetected(skill),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextButton(
                    onPressed: () => profile.dismissDetected(skill),
                    buttonText: 'Dismiss',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
