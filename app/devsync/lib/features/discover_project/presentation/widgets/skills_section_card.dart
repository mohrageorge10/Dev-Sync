import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Read-only categorized skills card on the public profile screen.
class SkillsSectionCard extends StatelessWidget {
  final Map<String, List<String>> initialSkillsCategories;

  const SkillsSectionCard({
    super.key,
    this.initialSkillsCategories = const {
      'LANGUAGES': ['Dart', 'Kotlin', 'Swift', 'Python'],
      'FRAMEWORKS & TOOLS': [
        'Flutter (Core)',
        'Android SDK',
        'Riverpod',
        'Firebase',
        'Figma',
        'Git / GitHub',
      ],
      'LEADERSHIP & COLLABORATION': [
        'Architectural Reviews',
        'Agile Sprints',
        'Team Mentorship',
      ],
    },
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 2),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in initialSkillsCategories.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppStyles.body11Bold(
                      context,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in entry.value)
                        entry.key == 'LEADERSHIP & COLLABORATION'
                            ? AppBadge.info(context, skill)
                            : AppSkillChip(label: skill),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
