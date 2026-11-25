import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Top bar for onboarding showing the DevSync brand and an optional Skip action.
class OnboardingTopBar extends StatelessWidget implements PreferredSizeWidget {
  const OnboardingTopBar({
    super.key,
    required this.showSkip,
    required this.onSkip,
  });

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AppBar(
      backgroundColor: c.backgroundPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          const DevSyncLogo(size: 32, borderRadius: 8),
          const SizedBox(width: 8),
          Text('DevSync', style: AppStyles.title17Bold(context)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IgnorePointer(
            ignoring: !showSkip,
            child: AnimatedOpacity(
              opacity: showSkip ? 1 : 0,
              duration: AppAnimations.fast,
              child: TextButton(
                onPressed: onSkip,
                child: Text('Skip', style: AppStyles.gray_16_500(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
