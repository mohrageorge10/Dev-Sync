import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/screens/behance/disconnect_behance_dialog.dart';
import 'package:devsync/features/profile/presentation/screens/github/disconnect_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_footer.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Step 5 of profile setup: connect GitHub and external showcase accounts.
class ConnectWorkScreen extends StatelessWidget {
  const ConnectWorkScreen({super.key});

  Future<void> _continue(
    BuildContext context,
    ProfileController profile,
  ) async {
    await profile.saveProfile();
    if (!context.mounted) return;
    Navigator.pushNamed(context, AppRoutes.profileComplete);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'Connect Accounts',
      footer: ProfileStepFooter(
        blockedReason: profile.connectWorkBlockedReason,
        onContinue: () => _continue(context, profile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStepProgress(100),
          Text('Connect your work', style: AppStyles.h28(context)),
          const SizedBox(height: 4),
          Text(
            'Connected accounts help DevSync analyze your public repositories and contributions to detect real skills and recommend better-fitting teams.',
            style: AppStyles.body13Secondary(context),
          ),
          const SizedBox(height: 16),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AppImages.githubLogo,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        c.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GitHub', style: AppStyles.body13Bold(context)),
                          Text(
                            'Code & Repositories',
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ),
                    ),
                    if (profile.githubConnected)
                      ProfileTag(
                        'Connected',
                        fg: c.success,
                        bg: c.subtle(c.success),
                      )
                    else
                      const ProfileTag('Required'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sync your public repositories, languages, and commit history to automatically verify your tech stack.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 12),
                if (profile.githubConnected)
                  Row(
                    children: [
                      Expanded(
                        child: ProfileSoftButton(
                          'Review skills',
                          icon: Icons.auto_awesome,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            profile.analysis == null
                                ? AppRoutes.profileGithubAnalysis
                                : AppRoutes.profileGithubReview,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileSoftButton(
                          'Disconnect',
                          icon: Icons.link_off,
                          onPressed: () async {
                            final confirmed = await showDisconnectGithubDialog(
                              context,
                              keptSkills: profile.addedCount,
                            );
                            if (confirmed) {
                              profile.disconnectGithub();
                              await profile.saveProfile();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                else
                  ProfileSoftButton(
                    'Connect GitHub',
                    icon: Icons.link,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.profileGithubConnect,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 12, color: c.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'We only read public data needed for matching. You can disconnect anytime.',
                        style: AppStyles.caption10Secondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Bē', style: AppStyles.h20(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Behance', style: AppStyles.body13Bold(context)),
                          Text(
                            'Portfolio & Showcase',
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ),
                    ),
                    if (profile.behanceConnected)
                      ProfileTag(
                        'Connected',
                        fg: c.success,
                        bg: c.subtle(c.success),
                      )
                    else
                      const ProfileTag('Design & UI/UX'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Showcase your design portfolio, UI/UX tools, and featured Behance case studies.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 12),
                if (profile.behanceConnected)
                  Row(
                    children: [
                      Expanded(
                        child: ProfileSoftButton(
                          'Edit Portfolio',
                          icon: Icons.palette_outlined,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.profileBehanceConnect,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileSoftButton(
                          'Disconnect',
                          icon: Icons.link_off,
                          onPressed: () async {
                            final confirmed = await showDisconnectBehanceDialog(
                              context,
                              shotsCount:
                                  profile.behanceProfile?.shots.length ?? 0,
                            );
                            if (confirmed) {
                              profile.disconnectBehance();
                              await profile.saveProfile();
                            }
                          },
                        ),
                      ),
                    ],
                  )
                else
                  ProfileSoftButton(
                    'Connect Behance',
                    icon: Icons.palette_outlined,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.profileBehanceConnect,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            color: c.subtleBlueSurface,
            borderColor: Colors.transparent,
            child: Row(
              children: [
                Icon(Icons.hub_outlined, color: c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Project Matching',
                        style: AppStyles.body12Bold(context),
                      ),
                      Text(
                        'Profiles with connected proof of work receive up to 3.8x more team invites.',
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
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
