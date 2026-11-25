import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:flutter/material.dart';

// Card allowing the user to set proficiency per selected programming language.
class LanguageProficiencyCard extends StatelessWidget {
  const LanguageProficiencyCard({super.key, required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'LANGUAGE PROFICIENCY SETTINGS',
                  style: AppStyles.caption10Bold(
                    context,
                    color: c.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                'Tap to modify',
                style: AppStyles.body11Bold(context, color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final entry in profile.languages.entries)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
              decoration: BoxDecoration(
                color: c.backgroundPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: AppStyles.body13Bold(context, color: c.primary),
                  ),
                  Text('  •  ', style: AppStyles.body11Secondary(context)),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: entry.value,
                      isDense: true,
                      dropdownColor: c.backgroundPrimary,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      style: AppStyles.body12Primary(context),
                      items: ProfileController.levels
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) profile.setProficiency(entry.key, v);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => profile.toggleLanguage(entry.key),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 14, color: c.textPrimary),
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
