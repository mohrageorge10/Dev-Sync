import 'package:flutter/material.dart';

import '../../widgets/profile_widgets.dart';
import '../../../data/models/detected_skill.dart';
import '../../cubit/profile_controller.dart';
import 'disconnect_dialog.dart';

class ReviewSkillsScreen extends StatelessWidget {
  const ReviewSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    final a = c.analysis;
    if (a == null)
      return const AppScaffold(
        title: 'Review Detected Skills',
        child: SizedBox(),
      );
    final visible = a.skills
        .where((s) => s.status != SkillStatus.dismissed)
        .toList();

    return AppScaffold(
      title: 'Review Detected Skills',
      actions: [
        IconButton(
          tooltip: 'Disconnect GitHub',
          icon: const Icon(Icons.link_off, size: 20),
          onPressed: () async {
            final ok = await showDisconnectGithubDialog(
              context,
              keptSkills: c.addedCount,
            );
            if (ok && context.mounted) {
              c.disconnectGithub();
              Navigator.pop(context);
            }
          },
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            'Save Selected Skills (${c.addedCount} added)',
            icon: Icons.save_outlined,
            onPressed: () => Navigator.pop(context),
          ),
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
                  color: ProfileColors.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: ProfileColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills we detected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'These are suggestions based on your activity. Add only what\'s accurate.',
                      style: ProfileStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            color: ProfileColors.subtleBlueSurface,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(10),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: ProfileColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'AI Suggestions • Never added without your approval',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(a),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Detected Skill Suggestions',
                style: ProfileStyles.cardTitleLarge,
              ),
              const SizedBox(width: 6),
              Tag('${a.skills.length} total'),
              const Spacer(),
              if (c.pendingSuggestions.isNotEmpty)
                GestureDetector(
                  onTap: c.addAllDetected,
                  child: const Text(
                    'Add all',
                    style: TextStyle(
                      color: ProfileColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final s in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SkillCard(skill: s, c: c),
            ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No more suggestions.',
                  style: TextStyle(color: ProfileColors.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _langColors = [
  Color(0xFF2B5BE0),
  Color(0xFF5D6B98),
  Color(0xFF7AA2FF),
  Color(0xFFB4C0DD),
];

class _SummaryCard extends StatelessWidget {
  final GithubAnalysis a;
  const _SummaryCard(this.a);
  @override
  Widget build(BuildContext context) {
    final entries = a.languages.entries.toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '@${a.username} activity summary',
                  style: ProfileStyles.cardTitle,
                ),
              ),
              const Tag(
                'Public data',
                fg: ProfileColors.textSecondary,
                bg: ProfileColors.surface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                for (var i = 0; i < entries.length; i++)
                  Expanded(
                    flex: entries[i].value,
                    child: Container(
                      height: 6,
                      color: _langColors[i % _langColors.length],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (var i = 0; i < entries.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: _langColors[i % _langColors.length],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entries[i].key} ${entries[i].value}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ProfileColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('${a.repos}', 'Repositories'),
                _Stat('${a.commits}', 'Commits (12m)'),
                _Stat('${a.prsMerged}', 'PRs Merged'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      Text(l, style: ProfileStyles.caption),
    ],
  );
}

class _SkillCard extends StatelessWidget {
  final DetectedSkill skill;
  final ProfileController c;
  const _SkillCard({required this.skill, required this.c});
  @override
  Widget build(BuildContext context) {
    final added = skill.status == SkillStatus.added;
    final high = skill.confidence == 'High';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(skill.name, style: ProfileStyles.sectionTitle),
              ),
              const SizedBox(width: 8),
              Tag(
                '${skill.confidence} Confidence',
                fg: high ? ProfileColors.primary : ProfileColors.textSecondary,
                bg: high
                    ? ProfileColors.subtleBlueSurface
                    : ProfileColors.surface,
              ),
              const Spacer(),
              if (!added)
                InkWell(
                  onTap: () => c.dismissDetected(skill),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: ProfileColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(skill.evidence, style: ProfileStyles.bodySmall),
          const SizedBox(height: 10),
          if (added)
            Row(
              children: [
                const Tag(
                  '✓ Added to profile',
                  fg: ProfileColors.primary,
                  bg: ProfileColors.subtleBlueSurface,
                ),
                const Spacer(),
                AppTextButton(
                  onPressed: () => c.undoDetected(skill),
                  buttonText: 'Undo',
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PrimaryButton(
                    'Add Skill',
                    icon: Icons.add,
                    onPressed: () => c.addDetected(skill),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextButton(
                    onPressed: () => c.dismissDetected(skill),
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
