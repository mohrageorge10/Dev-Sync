import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/snapshot/snapshot_credentials_section.dart';
import 'package:devsync/features/profile/presentation/widgets/snapshot/snapshot_header_card.dart';
import 'package:devsync/features/profile/presentation/widgets/snapshot/snapshot_skills_section.dart';
import 'package:flutter/material.dart';

// User profile overview showing completeness, skills, links, accounts, and sign out.
class DeveloperSnapshotScreen extends StatelessWidget {
  const DeveloperSnapshotScreen({
    super.key,
    this.embedded = false,
    this.onProfileUpdated,
  });

  final bool embedded;
  final VoidCallback? onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'My Profile',
      showBack: !embedded,
      actions: [
        IconButton(
          tooltip: 'Edit profile',
          icon: Icon(Icons.edit_outlined, size: 20, color: c.primary),
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.profileEdit);
            onProfileUpdated?.call();
          },
        ),
        IconButton(
          tooltip: 'Sign out',
          icon: Icon(Icons.logout_rounded, size: 20, color: c.error),
          onPressed: () => _confirmSignOut(context, profile),
        ),
      ],
      child: profile.isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SnapshotHeaderCard(profile: profile),
                SnapshotSkillsSection(profile: profile),
                SnapshotCredentialsSection(
                  profile: profile,
                  onProfileUpdated: onProfileUpdated,
                ),
              ],
            ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    ProfileController profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final c = dialogCtx.colors;
        return Dialog(
          backgroundColor: c.backgroundPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: c.subtle(c.error),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: c.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sign out?',
                        style: AppStyles.title17Bold(dialogCtx),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(dialogCtx, false),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'You will need to sign in again to access your saved projects and profile.',
                  style: AppStyles.body13Secondary(dialogCtx),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ProfileSoftButton(
                        'Cancel',
                        onPressed: () => Navigator.pop(dialogCtx, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ProfilePrimaryButton(
                        'Sign Out',
                        icon: Icons.logout_rounded,
                        color: c.error,
                        onPressed: () => Navigator.pop(dialogCtx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    await profile.signOut();
    if (ServiceLocator.isRegistered<DiscoverCubit>()) {
      ServiceLocator.get<DiscoverCubit>().reset();
    }
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.authEntry,
      (_) => false,
    );
  }
}
