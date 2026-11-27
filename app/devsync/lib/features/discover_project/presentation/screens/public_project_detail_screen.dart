import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:devsync/features/discover_project/data/repositories/discover_repository.dart';
import 'package:devsync/features/discover_project/presentation/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Public showcase detail screen for a portfolio project (awards, product link, and contributors).
class PublicProjectDetailScreen extends StatelessWidget {
  const PublicProjectDetailScreen({
    super.key,
    required this.project,
    this.isGuest = false,
  });

  final PortfolioProjectData project;
  final bool isGuest;

  Future<void> _openExternalUrl(BuildContext context, String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      AppFeedback.show(
        context,
        message: 'Could not open link',
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final statusColor = project.statusText.toLowerCase().contains('shipped')
        ? c.primary
        : project.isCompleted
        ? c.success
        : c.primary;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Project Showcase',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card with logo, title, type, status, and description.
          _CardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: project.logoUrl.isNotEmpty
                          ? Image.network(
                              project.logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                project.topIcon,
                                color: c.primary,
                                size: 26,
                              ),
                            )
                          : Icon(project.topIcon, color: c.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: AppStyles.title17Bold(context),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            project.period.isNotEmpty
                                ? '${project.badgeText} • ${project.period}'
                                : project.badgeText,
                            style: AppStyles.body12Secondary(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: c.subtle(statusColor),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        project.statusText,
                        style: AppStyles.body11Bold(
                          context,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    project.description,
                    style: AppStyles.body14Primary(context),
                  ),
                ],
                if (project.completionSummary.isNotEmpty &&
                    project.completionSummary != project.description) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(
                      project.completionSummary,
                      style: AppStyles.body13Primary(context),
                    ),
                  ),
                ],
                if (project.tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.tags
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: c.subtleBlueSurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              t,
                              style: AppStyles.body12Medium(
                                context,
                                color: c.primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (project.productUrl.isNotEmpty ||
                    project.repoUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (project.productUrl.isNotEmpty)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openExternalUrl(context, project.productUrl),
                            icon: const Icon(
                              Icons.rocket_launch_outlined,
                              size: 16,
                            ),
                            label: const Text('Live Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.primary,
                              foregroundColor: c.onPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (project.productUrl.isNotEmpty &&
                          project.repoUrl.isNotEmpty)
                        const SizedBox(width: 10),
                      if (project.repoUrl.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openExternalUrl(context, project.repoUrl),
                            icon: const Icon(Icons.code_rounded, size: 16),
                            label: const Text('Repository'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: c.textPrimary,
                              side: BorderSide(color: c.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Awards & Achievements section.
          if (project.awards.isNotEmpty) ...[
            const SizedBox(height: 14),
            _CardBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 20,
                        color: c.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Awards & Achievements',
                        style: AppStyles.title15Bold(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final award in project.awards) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: c.subtle(c.warning),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: c.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 18,
                            color: c.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              award,
                              style: AppStyles.body13Bold(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Team Contributors section fetched live from Firestore.
          const SizedBox(height: 14),
          _CardBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.groups_outlined, size: 20, color: c.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Team Contributors',
                      style: AppStyles.title15Bold(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<
                  List<({DeveloperModel developer, String teamRole, String track})>
                >(
                  future: ServiceLocator.isRegistered<DiscoverRepository>()
                      ? ServiceLocator.get<DiscoverRepository>()
                            .fetchProjectContributors(project.projectId)
                      : Future.value(const []),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final contributors = snapshot.data ?? const [];
                    if (contributors.isEmpty) {
                      return Text(
                        'No contributor details available.',
                        style: AppStyles.body13Secondary(context),
                      );
                    }
                    final currentUid =
                        ServiceLocator.isRegistered<DiscoverRepository>()
                        ? ServiceLocator.get<DiscoverRepository>().currentUserId
                        : null;
                    return Column(
                      children: [
                        for (var i = 0; i < contributors.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: c.border),
                          _ContributorTile(
                            developer: contributors[i].developer,
                            teamRole: contributors[i].teamRole,
                            track: contributors[i].track,
                            onTap: () => Navigator.of(context).push(
                              AppPageRoute(
                                builder: (_) => PublicProfileScreen(
                                  developer: contributors[i].developer,
                                  isGuest: isGuest,
                                  showBottomBar:
                                      contributors[i].developer.id !=
                                      currentUid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ContributorTile extends StatelessWidget {
  const _ContributorTile({
    required this.developer,
    required this.teamRole,
    required this.track,
    required this.onTap,
  });

  final DeveloperModel developer;
  final String teamRole;
  final String track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isOwner = teamRole == 'Owner';
    final initials = developer.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: c.subtleBlueSurface,
              backgroundImage:
                  developer.imageUrl != null && developer.imageUrl!.isNotEmpty
                  ? NetworkImage(developer.imageUrl!)
                  : null,
              child: developer.imageUrl == null || developer.imageUrl!.isEmpty
                  ? Text(
                      initials.isEmpty ? 'D' : initials,
                      style: AppStyles.body13Bold(context, color: c.primary),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          developer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.body14Bold(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? c.subtleBlueSurface
                              : c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isOwner
                                ? c.primary.withValues(alpha: 0.3)
                                : c.border,
                          ),
                        ),
                        child: Text(
                          teamRole,
                          style: AppStyles.body11Bold(
                            context,
                            color: isOwner ? c.primary : c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$track • ${developer.handle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.body12Secondary(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  const _CardBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}
