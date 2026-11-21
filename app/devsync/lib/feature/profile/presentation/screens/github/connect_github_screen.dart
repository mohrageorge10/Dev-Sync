import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../../widgets/profile_widgets.dart';

class ConnectGithubScreen extends StatelessWidget {
  const ConnectGithubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Connect GitHub',
      footer: Column(mainAxisSize: MainAxisSize.min, children: [
        PrimaryButton('Connect GitHub',
            icon: Icons.code,
            // يروح مباشرة لشاشة التحليل ثم الـ Review
            onPressed: () => Navigator.pushReplacementNamed(context, ProfileRoutes.githubAnalysis)),
        AppTextButton(onPressed: () => Navigator.pop(context), buttonText: 'Skip for Now'),
      ]),
      child: Column(children: [
        const SizedBox(height: 8),
        const CircleAvatar(radius: 34, backgroundColor: ProfileColors.subtleBlueSurface, child: Icon(Icons.code, size: 34, color: ProfileColors.textPrimary)),
        const SizedBox(height: 14),
        const Text('Connect your GitHub', style: ProfileStyles.title),
        const SizedBox(height: 6),
        const Text('DevSync reads your public activity to automatically detect skills, frameworks, and velocity from real code.',
            textAlign: TextAlign.center, style: ProfileStyles.subtitle),
        const SizedBox(height: 10),
        const Tag('AUTO-GENERATES VERIFIED SKILL BADGES'),
        const SizedBox(height: 18),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _Header(icon: Icons.visibility_outlined, title: 'What we read', badge: 'READ-ONLY'),
            _Row(Icons.check_circle, 'Repositories', 'Public repositories you created or actively contributed to.'),
            _Row(Icons.check_circle, 'Languages & Frameworks', 'Byte-level language ratios detected across merged commits.'),
            _Row(Icons.check_circle, 'Commit activity', 'Frequency, streaks, and recency of updates for team matching.'),
            _Row(Icons.check_circle, 'Pull requests & code reviews', 'Merged PRs and recognized collaborative open-source work.'),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            _Header(icon: Icons.shield_outlined, title: 'What we never do', trailing: Icons.lock_outline),
            Text('Zero compromise on code privacy', style: ProfileStyles.bodySmall),
            SizedBox(height: 8),
            _Row(Icons.block, 'No write access', 'We never modify code, push branches, or alter account settings.', neg: true),
            _Row(Icons.visibility_off_outlined, 'No private code reading', 'Proprietary repos remain 100% untouched and invisible.', neg: true),
            _Row(Icons.link_off, 'Disconnect anytime', 'Revoke OAuth tokens instantly with a single tap in Settings.', neg: true),
          ]),
        ),
      ]),
    );
  }
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final IconData? trailing;
  const _Header({required this.icon, required this.title, this.badge, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(icon, size: 16, color: ProfileColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: ProfileStyles.cardTitleLarge)),
          if (badge != null) Tag(badge!),
          if (trailing != null) Icon(trailing, size: 16, color: ProfileColors.textSecondary),
        ]),
      );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final bool neg;
  const _Row(this.icon, this.title, this.sub, {this.neg = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: neg ? ProfileColors.textSecondary : ProfileColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              Text(sub, style: const TextStyle(fontSize: 11, color: ProfileColors.textSecondary, height: 1.3)),
            ]),
          ),
        ]),
      );
}
