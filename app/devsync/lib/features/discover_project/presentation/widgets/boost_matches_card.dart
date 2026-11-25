import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Profile completion prompt card.
class BoostMatchesCard extends StatelessWidget {
  const BoostMatchesCard({
    super.key,
    this.strength = 0.6,
    this.onCompletePressed,
    this.onClosePressed,
  });

  final VoidCallback? onCompletePressed;
  final VoidCallback? onClosePressed;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final percent = (strength * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: c.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Boost Your Matches',
                  style: AppStyles.body14Bold(context),
                ),
              ),
              IconButton(
                onPressed: onClosePressed,
                icon: Icon(
                  Icons.close_rounded,
                  color: c.textSecondary,
                  size: 17,
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Strength',
                style: AppStyles.body11SemiBold(
                  context,
                  color: c.textSecondary,
                ),
              ),
              Text(
                '$percent%',
                style: AppStyles.body12Bold(context, color: c.primary),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation<Color>(c.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Your profile is $percent% complete. Finish it for better matches.',
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: onCompletePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Complete Profile',
                      style: AppStyles.body12SemiBold(
                        context,
                        color: c.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
              Text(
                'Takes 2 mins',
                style: AppStyles.body11Medium(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}