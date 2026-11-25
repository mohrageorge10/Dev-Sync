import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/app_bar/devsync_logo.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/cancel_application_dialog.dart';
import 'package:devsync/features/discover_project/presentation/widgets/developer_card.dart';
import 'package:devsync/features/discover_project/presentation/widgets/project_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Saved projects and developers screen synced with DiscoverCubit.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoverCubitScope(child: _SavedView());
  }
}

class _SavedView extends StatefulWidget {
  const _SavedView();

  @override
  State<_SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<_SavedView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: const CustomAppBar(
        title: 'Saved',
        leading: Align(alignment: Alignment.center, child: DevSyncLogo()),
      ),
      body: BlocBuilder<DiscoverCubit, DiscoverState>(
        builder: (context, state) {
          final cubit = context.read<DiscoverCubit>();
          final projects = state.savedProjects;
          final developers = state.savedDevelopers;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSegmentedControl(
                  labels: [
                    'Projects (${projects.length})',
                    'Developers (${developers.length})',
                  ],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppAnimations.normal,
                    child: _tab == 0
                        ? _SavedProjectsList(
                            key: const ValueKey('saved_projects'),
                            state: state,
                            cubit: cubit,
                          )
                        : _SavedDevelopersList(
                            key: const ValueKey('saved_developers'),
                            state: state,
                            cubit: cubit,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SavedProjectsList extends StatelessWidget {
  const _SavedProjectsList({
    super.key,
    required this.state,
    required this.cubit,
  });

  final DiscoverState state;
  final DiscoverCubit cubit;

  @override
  Widget build(BuildContext context) {
    final items = state.savedProjects;
    if (items.isEmpty) {
      return const _EmptySavedState(
        icon: Icons.bookmark_border_rounded,
        title: 'No saved projects yet',
        subtitle:
            'Tap the bookmark icon on any project to save it here for quick access.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final project = items[i];
        return AppFadeSlide(
          delay: Duration(milliseconds: 40 * i),
          child: ProjectCard(
            project: project,
            isSaved: true,
            isApplied: state.isProjectApplied(project.id),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.projectDetails,
              arguments: project,
            ),
            onBookmark: () {
              cubit.toggleProjectSaved(project.id);
              AppFeedback.show(
                context,
                message: 'Removed "${project.title}" from saved.',
              );
            },
            onApply: () async {
              if (state.isProjectApplied(project.id)) {
                final confirmed = await showCancelApplicationDialog(
                  context,
                  projectTitle: project.title,
                );
                if (!confirmed || !context.mounted) return;
                await cubit.cancelApplication(project.id);
                if (!context.mounted) return;
                AppFeedback.show(
                  context,
                  title: 'Application cancelled',
                  message:
                      'Withdrew your request to join "${project.title}".',
                  type: AppFeedbackType.info,
                );
                return;
              }
              cubit.applyToProject(project.id);
              AppFeedback.show(
                context,
                title: 'Application sent',
                message: 'Your request to join "${project.title}" was sent.',
                type: AppFeedbackType.success,
              );
            },
          ),
        );
      },
    );
  }
}

class _SavedDevelopersList extends StatelessWidget {
  const _SavedDevelopersList({
    super.key,
    required this.state,
    required this.cubit,
  });

  final DiscoverState state;
  final DiscoverCubit cubit;

  @override
  Widget build(BuildContext context) {
    final items = state.savedDevelopers;
    if (items.isEmpty) {
      return const _EmptySavedState(
        icon: Icons.person_outline_rounded,
        title: 'No saved developers yet',
        subtitle:
            'Bookmark developers you want to collaborate with to find them quickly here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final developer = items[i];
        return AppFadeSlide(
          delay: Duration(milliseconds: 40 * i),
          child: DeveloperCard(
            developer: developer,
            isSaved: true,
            onViewProfile: () => Navigator.of(context).pushNamed(
              AppRoutes.publicProfile,
              arguments: developer,
            ),
            onBookmark: () {
              cubit.toggleDeveloperSaved(developer.id);
              AppFeedback.show(
                context,
                message: 'Removed ${developer.name} from saved.',
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.subtleBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: c.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppStyles.title16Bold(context)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppStyles.body13Secondary(context),
            ),
          ],
        ),
      ),
    );
  }
}
