import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../../../data/models/applicant_model.dart';
import '../section_card.dart';
import '../status_chip.dart';
import '../user_avatar.dart';

// Header card displaying applicant identity, level, location, match score, and profile link.
class ApplicantHeaderCard extends StatelessWidget {
  const ApplicantHeaderCard({
    super.key,
    required this.applicant,
    this.onViewProfile,
  });

  final ApplicantModel applicant;
  final VoidCallback? onViewProfile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: applicant.name, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.name, style: AppStyles.title16Bold(context)),
                    const SizedBox(height: 2),
                    Text(
                      applicant.title,
                      style: AppStyles.body12Secondary(context),
                    ),
                    if (applicant.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              applicant.location,
                              style: AppStyles.body12Secondary(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: '${applicant.matchPercent}% Match',
                          color: c.success,
                          background: c.subtle(c.success),
                        ),
                        if (applicant.level.trim().isNotEmpty)
                          StatusChip(
                            label: applicant.level,
                            color: c.primary,
                            background: c.subtle(c.primary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onViewProfile != null) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: c.border),
            const SizedBox(height: 8),
            InkWell(
              onTap: onViewProfile,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 17,
                      color: c.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'View Full Profile (GitHub, CV & Portfolio)',
                        style: AppStyles.body13SemiBold(
                          context,
                          color: c.primary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: c.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
