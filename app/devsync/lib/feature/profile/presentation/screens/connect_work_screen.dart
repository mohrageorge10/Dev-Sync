import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';
import 'github/disconnect_dialog.dart';

class ConnectWorkScreen extends StatelessWidget {
  const ConnectWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    return AppScaffold(
      title: 'Profile Details',
      footer: PrimaryButton('Continue', icon: Icons.arrow_forward, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.complete)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StepProgress(100),
        const Text('Connect your work', style: ProfileStyles.title),
        const SizedBox(height: 4),
        const Text('Connected accounts help DevSync analyze your public repositories and contributions to detect real skills and recommend better-fitting teams.',
            style: ProfileStyles.subtitle),
        const SizedBox(height: 16),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.code, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('GitHub', style: ProfileStyles.cardTitleLarge),
                  Text('Code & Repositories', style: ProfileStyles.caption),
                ]),
              ),
              if (c.githubConnected) const Tag('Connected', fg: ProfileColors.success, bg: ProfileColors.successSoft) else const Tag('Recommended'),
            ]),
            const SizedBox(height: 8),
            const Text('Sync your public repositories, languages, and commit history to automatically verify your tech stack.',
                style: ProfileStyles.bodySmallRelaxed),
            const SizedBox(height: 12),
            if (c.githubConnected)
              Row(children: [
                Expanded(child: SoftButton('Review skills', icon: Icons.auto_awesome, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.githubReview))),
                const SizedBox(width: 8),
                Expanded(
                  child: SoftButton('Disconnect', icon: Icons.link_off, onPressed: () async {
                    if (await showDisconnectGithubDialog(context, keptSkills: c.addedCount)) c.disconnectGithub();
                  }),
                ),
              ])
            else
              SoftButton('Connect GitHub', icon: Icons.link, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.githubConnect)),
            const SizedBox(height: 8),
            const Row(children: [
              Icon(Icons.lock_outline, size: 12, color: ProfileColors.textSecondary),
              SizedBox(width: 6),
              Expanded(child: Text('We only read public data needed for matching. You can disconnect anytime.', style: ProfileStyles.caption)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Text('Bē', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Behance', style: ProfileStyles.cardTitleLarge),
                  Text('Portfolio & Showcase', style: ProfileStyles.caption),
                ]),
              ),
              Tag('Design & UI/UX'),
            ]),
            const SizedBox(height: 8),
            const Text('Import design portfolios and creative case studies if you contribute to UI/UX tracks.', style: ProfileStyles.bodySmall),
            const SizedBox(height: 12),
            SoftButton('Connect Behance', icon: Icons.palette_outlined, onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Behance integration coming soon.')));
            }),
          ]),
        ),
        const SizedBox(height: 12),
        const AppCard(
          color: ProfileColors.subtleBlueSurface,
          borderColor: Colors.transparent,
          child: Row(children: [
            Icon(Icons.hub_outlined, color: ProfileColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Smart Project Matching', style: ProfileStyles.cardTitle),
                Text('Profiles with connected proof of work receive up to 3.8x more team invites.', style: ProfileStyles.bodySmall),
              ]),
            ),
          ]),
        ),
        Center(child: AppTextButton(onPressed: () => Navigator.pushNamed(context, ProfileRoutes.complete), buttonText: 'Skip for Now')),
      ]),
    );
  }
}
