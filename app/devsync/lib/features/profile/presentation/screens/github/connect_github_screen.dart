import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/services/github_service.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Intro screen for entering a GitHub username and launching real GitHub REST API analysis.
class ConnectGithubScreen extends StatefulWidget {
  const ConnectGithubScreen({super.key});

  @override
  State<ConnectGithubScreen> createState() => _ConnectGithubScreenState();
}

class _ConnectGithubScreenState extends State<ConnectGithubScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final profile = ProfileScope.of(context);
      final existing = GithubService.extractUsername(profile.githubUrl);
      if (existing.isNotEmpty) {
        _usernameCtrl.text = existing;
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _startConnect() {
    final handle = GithubService.extractUsername(_usernameCtrl.text);
    if (handle.isEmpty) {
      AppFeedback.show(
        context,
        message: 'Please enter your GitHub username or profile link',
        type: AppFeedbackType.error,
      );
      return;
    }
    final profile = ProfileScope.of(context);
    profile.setLinks(github: 'https://github.com/$handle');
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.profileGithubAnalysis,
      arguments: handle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasUsername =
        GithubService.extractUsername(_usernameCtrl.text).isNotEmpty;

    return ProfileScaffold(
      title: 'Connect GitHub',
      footer: ProfilePrimaryButton(
        'Connect & Analyze GitHub',
        icon: Icons.code,
        onPressed: hasUsername ? _startConnect : null,
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
            'Enter your GitHub username so DevSync can read your public repositories, languages, and PR activity.',
            textAlign: TextAlign.center,
            style: AppStyles.body13Secondary(context),
          ),
          const SizedBox(height: 10),
          const ProfileTag('AUTO-GENERATES VERIFIED SKILL BADGES'),
          const SizedBox(height: 18),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GitHub Username or Profile URL',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameCtrl,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _startConnect(),
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText: 'e.g. octocat or github.com/octocat',
                    hintStyle: AppStyles.body13Secondary(context),
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      size: 18,
                      color: c.primary,
                    ),
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                  'Byte-level language ratios detected across public repos.',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Commit activity',
                  'Recent public push activity and stars for team matching.',
                ),
                _PermissionRow(
                  Icons.check_circle,
                  'Pull requests',
                  'Merged PRs and collaborative open-source work.',
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
                  'Private repositories remain 100% untouched and invisible.',
                  negative: true,
                ),
                const _PermissionRow(
                  Icons.link_off,
                  'Disconnect anytime',
                  'Remove your linked GitHub handle with a single tap.',
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: negative ? c.error : c.success,
          ),
          const SizedBox(width: 8),
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
