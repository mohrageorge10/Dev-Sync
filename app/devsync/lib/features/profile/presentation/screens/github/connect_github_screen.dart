import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Intro screen explaining read-only GitHub permissions before launching analysis.
class ConnectGithubScreen extends StatelessWidget {
  const ConnectGithubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ProfileScaffold(
      title: 'Connect GitHub',
      footer: ProfilePrimaryButton(
        'Connect GitHub',
        icon: Icons.code,
        onPressed: () => Navigator.pushReplacementNamed(
          context,
          AppRoutes.profileGithubAnalysis,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          CircleAvatar(
            radius: 34,
            backgroundColor: c.subtleBlueSurface,
            child: SvgPicture.asset(
              AppImages.githubLogo,
              width: 34,
              height: 34,
              colorFilter: ColorFilter.mode(
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Connect your GitHub', style: AppStyles.h28(context)),
          const SizedBox(height: 6),
          Text(
            'DevSync reads your public activity to automatically detect skills, frameworks, and velocity from real code.',
            textAlign: TextAlign.center,
            style: AppStyles.body13Secondary(context),
          ),
          const SizedBox(height: 10),
          const ProfileTag('AUTO-GENERATES VERIFIED SKILL BADGES'),
          const SizedBox(height: 18),
          const ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  icon: Icons.visibility_outlined,
                  title: 'What we read',
                  badge: 'READ-ONLY',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Repositories',
                  'Public repositories you created or actively contributed to.',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Languages & Frameworks',
                  'Byte-level language ratios detected across merged commits.',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Commit activity',
                  'Frequency, streaks, and recency of updates for team matching.',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Pull requests & code reviews',
                  'Merged PRs and recognized collaborative open-source work.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  icon: Icons.shield_outlined,
                  title: 'What we never do',
                  trailing: Icons.lock_outline,
                ),
                Text(
                  'Zero compromise on code privacy',
                  style: AppStyles.body11Secondary(context),
                ),
                const SizedBox(height: 8),
                const _PermissionRow(
                  Icons.block,
                  'No write access',
                  'We never modify code, push branches, or alter account settings.',
                  negative: true,
                ),
                const _PermissionRow(
                  Icons.visibility_off_outlined,
                  'No private code reading',
                  'Proprietary repos remain 100% untouched and invisible.',
                  negative: true,
                ),
                const _PermissionRow(
                  Icons.link_off,
                  'Disconnect anytime',
                  'Revoke OAuth tokens instantly with a single tap in Settings.',
                  negative: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.badge,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? badge;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: AppStyles.body13Bold(context))),
          if (badge != null) ProfileTag(badge!),
          if (trailing != null) Icon(trailing, size: 16, color: c.textSecondary),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow(
    this.icon,
    this.title,
    this.subtitle, {
    this.negative = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: negative ? c.textSecondary : c.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppStyles.body12Bold(context)),
                Text(subtitle, style: AppStyles.body11Secondary(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
