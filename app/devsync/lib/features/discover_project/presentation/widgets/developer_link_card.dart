import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/cards/app_developer_card.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:flutter/material.dart';

// Clickable developer card that opens the public profile screen.
class DeveloperLinkCard extends StatelessWidget {
  const DeveloperLinkCard({
    super.key,
    required this.developer,
    this.isGuest = false,
    this.onConnect,
  });

  final DeveloperModel developer;
  final bool isGuest;
  final VoidCallback? onConnect;

  void _openProfile(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.publicProfile,
      arguments: (developer: developer, isGuest: isGuest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openProfile(context),
          child: DeveloperProfileCard(
            name: developer.name,
            username: developer.username,
            title: developer.subtitle,
            skills: developer.skills,
            avatarUrl: developer.imageUrl ?? '',
            githubConnected: developer.hasGithub,
            matchPercent: developer.matchPercent,
            matchReason: developer.bio,
          ),
        ),
        if (onConnect != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppSecondaryButton(
              buttonText: 'Connect',
              leadingIcon: Icons.person_add_alt_1_outlined,
              onPressed: onConnect!,
            ),
          ),
        ],
      ],
    );
  }
}
