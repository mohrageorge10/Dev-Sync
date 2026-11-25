import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_compact_button.dart';
import 'package:flutter/material.dart';

// Single row in the profile verification checklist.
class ChecklistItemRow extends StatelessWidget {
  const ChecklistItemRow({super.key, required this.item, required this.onAdd});

  final ChecklistItem item;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.done ? c.success : null,
              border: item.done ? null : Border.all(color: c.border, width: 1.5),
            ),
            child: item.done
                ? Icon(Icons.check, size: 14, color: c.onPrimary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppStyles.body12Bold(context)),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.caption10Secondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.done)
            ProfileTag('Completed', fg: c.success, bg: c.subtle(c.success))
          else
            ProfileCompactButton('+ Add', onPressed: onAdd),
        ],
      ),
    );
  }
}

// Bottom status card showing either remaining steps or 100% completion celebration.
class CompletionStatusCard extends StatelessWidget {
  const CompletionStatusCard({
    super.key,
    required this.completion,
    required this.missingCount,
    required this.onCompleteNext,
  });

  final int completion;
  final int missingCount;
  final VoidCallback onCompleteNext;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (completion < 100) {
      return ProfileCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: c.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Boost Match Relevance',
                    style: AppStyles.body12Bold(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Your profile is $completion% complete. Finish it for better matches.',
              style: AppStyles.body11Secondary(context),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completion / 100,
                minHeight: 4,
                backgroundColor: c.border,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$missingCount step${missingCount == 1 ? '' : 's'} remaining',
                    style: AppStyles.caption10Secondary(context),
                  ),
                ),
                ProfileCompactButton(
                  'Complete Profile',
                  onPressed: onCompleteNext,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [c.backgroundPrimary, c.subtleBlueSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.subtle(c.success),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.verified_user, color: c.success, size: 24),
          ),
          const SizedBox(height: 8),
          ProfileTag(
            'Top Match Unlocked',
            fg: c.success,
            bg: c.subtle(c.success),
          ),
          const SizedBox(height: 10),
          Text(
            'Your profile is 100% complete!',
            textAlign: TextAlign.center,
            style: AppStyles.title16Bold(context),
          ),
          const SizedBox(height: 4),
          Text(
            'You are now ready for precision AI team matching and high-priority project recommendations.',
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 14),
          ProfilePrimaryButton(
            'Explore Projects',
            icon: Icons.explore_outlined,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.main,
              (_) => false,
            ),
          ),
          const SizedBox(height: 10),
          AppTextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profileSnapshot),
            buttonText: 'View Developer Profile',
          ),
        ],
      ),
    );
  }
}
