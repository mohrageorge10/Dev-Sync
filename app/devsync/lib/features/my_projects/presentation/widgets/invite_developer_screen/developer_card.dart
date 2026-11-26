import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/developer_model.dart';
import '../section_card.dart';
import '../skill_chip.dart';
import '../status_chip.dart';
import '../user_avatar.dart';

// Developer summary card displayed on the Invite Developer screen.
class DeveloperCard extends StatelessWidget {
  const DeveloperCard({super.key, required this.developer});

  final DeveloperModel developer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: developer.name, radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(developer.name, style: AppStyles.title16Bold(context)),
                    Text(
                      developer.title,
                      style: AppStyles.body12Secondary(context),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: '${developer.fitPercent}% Fit',
                color: c.success,
                background: c.subtle(c.success),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SkillWrap(developer.skills),
        ],
      ),
    );
  }
}
