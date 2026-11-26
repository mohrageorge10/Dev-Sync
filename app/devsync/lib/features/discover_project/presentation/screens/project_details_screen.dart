import 'package:devsync/core/animations/app_fade_slide.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/headers/header.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_state.dart';
import 'package:devsync/features/discover_project/presentation/widgets/bookmark_button.dart';
import 'package:devsync/features/discover_project/presentation/widgets/cancel_application_dialog.dart';
import 'package:devsync/features/discover_project/presentation/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project details screen displaying overview, match insight, stack, tracks, and apply action.
class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return DiscoverCubitScope(
      child: _ProjectDetailsView(project: project),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Project Details',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: c.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
        child: Column(
          spacing: 18,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero summary card.
            AppFadeSlide(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: c.backgroundPrimary,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: c.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: c.subtleBlueSurface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(project.icon, color: c.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              project.isRealWorld
                                  ? AppBadge.realWorld(context)
                                  : AppBadge.learning(context),
                              project.isOpen
                                  ? AppBadge.success(context, 'Open')
                                  : AppBadge.info(context, 'Full'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(project.title, style: AppStyles.h2(context)),
                    const SizedBox(height: 6),
                    Text(
                      '${project.createdAgo} • ${project.status}',
                      style: AppStyles.body12Secondary(context),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      project.description,
                      style: AppStyles.body14Secondary(context),
                    ),
                    const SizedBox(height: 14),
                    InfoBanner(
                      text:
                          '${project.matchPercentageText} — ${project.matchReason}',
                    ),
                  ],
                ),
              ),
            ),

            // Quick stats row.
            AppFadeSlide(
              delay: const Duration(milliseconds: 70),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.group_outlined,
                      label: 'Team',
                      value: '${project.members}/${project.maxMembers}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.signal_cellular_alt,
                      label: 'Difficulty',
                      value: project.difficulty,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetricTile(
                      icon: Icons.bolt_rounded,
                      label: 'Match',
                      value: '${project.matchPercent}%',
                    ),
                  ),
                ],
              ),
            ),

            // Tech stack.
            AppFadeSlide(
              delay: const Duration(milliseconds: 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header(title: 'Tech Stack', text: 'Required'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.backgroundPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in project.tags)
                          AppSkillChip(label: tag),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Open tracks & roles needed.
            AppFadeSlide(
              delay: const Duration(milliseconds: 190),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header(title: 'Tracks & Roles Needed', text: 'Open'),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.backgroundPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final track in project.tracks)
                              AppBadge.info(context, track),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Currently looking for: ${project.needs}',
                          style: AppStyles.body13Primary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.backgroundPrimary,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: BlocBuilder<DiscoverCubit, DiscoverState>(
            builder: (context, state) {
              final cubit = context.read<DiscoverCubit>();
              final isSaved = state.isProjectSaved(project.id);
              final isApplied = state.isProjectApplied(project.id);
              final canApply = state.canApplyTo(project);

              return Row(
                children: [
                  BookmarkButton(
                    isSaved: isSaved,
                    size: 48,
                    onTap: () {
                      cubit.toggleProjectSaved(project.id);
                      AppFeedback.show(
                        context,
                        message: isSaved
                            ? 'Removed "${project.title}" from saved.'
                            : 'Saved "${project.title}" to Saved.',
                        type: isSaved
                            ? AppFeedbackType.info
                            : AppFeedbackType.success,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isApplied
                        ? InkWell(
                            onTap: () async {
                              final confirmed =
                                  await showCancelApplicationDialog(
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
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: c.subtle(c.error),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: c.error.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: c.error,
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Cancel Application',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.body14Bold(
                                        context,
                                        color: c.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : AppPrimaryButton(
                            buttonText: !project.isOpen
                                ? 'Team Full'
                                : !canApply
                                ? 'Track / Skills Mismatch'
                                : 'Apply to Join',
                            trailingIcon: Icons.arrow_forward_rounded,
                            isDisabled: !canApply,
                            onPressed: () {
                              cubit.applyToProject(project.id);
                              AppFeedback.show(
                                context,
                                title: 'Application sent',
                                message:
                                    'Your request to join "${project.title}" was sent.',
                                type: AppFeedbackType.success,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body14Bold(context),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.body11Secondary(context)),
        ],
      ),
    );
  }
}
