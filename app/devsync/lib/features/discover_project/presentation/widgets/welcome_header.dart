import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Greeting header on the home screen.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    required this.greeting,
    required this.userName,
    this.onAiTap,
  });

  final String greeting;
  final String userName;
  final VoidCallback? onAiTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName 👋',
                style: AppStyles.h20(context),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Here are today's top curated opportunities",
                style: AppStyles.body13Secondary(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onAiTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.subtleBlueSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              color: c.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}