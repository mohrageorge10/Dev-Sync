import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/insights/insights_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 3: Review and publish screen.
class ReviewPublishScreen extends StatelessWidget {
  const ReviewPublishScreen({
    super.key,
    this.onEditDetails,
    this.onEditTeam,
    this.onBack,
    this.embedded = false,
  });

  final VoidCallback? onEditDetails;
  final VoidCallback? onEditTeam;
  final VoidCallback? onBack;
  final bool embedded;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final draft = context.watch<DraftCubit>().state.draft;
    final team = context.watch<TeamCubit>().state;
    final insights = context.watch<InsightsCubit>().state;
    final publishing = context.watch<PublishCubit>().state is PublishLoading;
    final totalSize = 1 + team.totalPeople;

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Hero card.
        SoftCard(
          color: c.subtleBlueSurface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FINAL STEP', style: AppStyles.overline9Bold(context)),
                    const SizedBox(height: 4),
                    Text('Ready to launch?', style: AppStyles.h3(context)),
                    const SizedBox(height: 4),
                    Text(
                      'Publishing creates your project, initializes your team, and sends queued invitations.',
                      style: AppStyles.body11Secondary(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.rocket_launch_outlined, size: 42, color: c.primary),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Project details summary.
        _Section(
          title: 'Project Details',
          icon: Icons.info_outline,
          onEdit: () => onEditDetails?.call(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: c.subtleBlueSurface,
                    child: Icon(draft.purpose.icon, color: c.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                draft.title,
                                style: AppStyles.title15Bold(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            draft.purpose == ProjectPurpose.real
                                ? AppBadge.realWorld(context)
                                : AppBadge.learning(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          draft.description,
                          style: AppStyles.body12Secondary(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: c.border, height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaPill(
                    draft.ownerTrack.icon,
                    'Your Track: ${draft.ownerTrack.label}',
                  ),
                  _MetaPill(
                    Icons.bar_chart_rounded,
                    'Difficulty: ${draft.difficulty.label}',
                  ),
                  if (draft.expectedEndDate != null)
                    _MetaPill(
                      Icons.event_outlined,
                      'Target: ${_formatDate(draft.expectedEndDate!)}',
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tech stack summary.
        _Section(
          title: 'Tech Stack',
          icon: Icons.layers_outlined,
          onEdit: () => onEditTeam?.call(),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in insights.techStack) AppSkillChip(label: s),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Repository & Git rules summary.
        _Section(
          title: 'Repository & Git Rules',
          icon: Icons.code_rounded,
          onEdit: () => onEditDetails?.call(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MetaPill(
                    Icons.account_tree_outlined,
                    'Base: ${draft.defaultBranch}',
                  ),
                  if (draft.repoUrl.trim().isNotEmpty)
                    _MetaPill(
                      Icons.link_rounded,
                      draft.repoUrl.replaceFirst(RegExp(r'^https?://'), ''),
                    ),
                ],
              ),
              if (draft.activeGitRules.isNotEmpty) ...[
                const SizedBox(height: 8),
                for (final rule in draft.activeGitRules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 13,
                          color: c.success,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rule,
                            style: AppStyles.body11Primary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Team structure summary.
        _Section(
          title:
              'Team Structure (1/$totalSize Filled · ${team.pendingInvites} Invited)',
          icon: Icons.groups_2_outlined,
          onEdit: () => onEditTeam?.call(),
          child: Column(
            children: [
              // Owner seat.
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(draft.ownerTrack.icon, size: 18, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${draft.ownerTrack.label} (You · Owner)',
                        style: AppStyles.body12Bold(context),
                      ),
                    ),
                    AppBadge.success(context, 'Filled'),
                  ],
                ),
              ),

              // Open track slots.
              for (final t in team.tracks)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.secondarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(t.definition.icon, size: 18, color: c.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t.definition.name} Teammates',
                                  style: AppStyles.body12Bold(context),
                                ),
                                Text(
                                  (t.skills.isNotEmpty
                                          ? t.skills
                                          : t.definition.skills.take(2))
                                      .join(' · '),
                                  style: AppStyles.caption10Secondary(context),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${t.people} needed (${t.openSpots} open)',
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ),
                      if (t.invites.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final inv in t.invites)
                              AppBadge.warning(
                                context,
                                'Invite: ${inv.builder.name} (${inv.builder.displayHandle})',
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Launch checklist.
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Launch checklist', style: AppStyles.body12Bold(context)),
              const SizedBox(height: 8),
              for (final i in insights.checklist)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        i.done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: i.done
                            ? c.success
                            : (i.required ? c.error : c.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${i.label}${i.required ? '' : ' (optional)'}',
                        style: AppStyles.body11Primary(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Publish and Save Draft buttons.
        AppPrimaryButton(
          buttonText: publishing ? 'Publishing...' : 'Publish Project',
          leadingIcon: publishing ? null : Icons.send_outlined,
          isDisabled: !insights.canPublish || publishing,
          onPressed: () => context.read<PublishCubit>().publish(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (onBack != null) ...[
              AppTextButton(buttonText: 'Previous', onPressed: onBack!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: AppSecondaryButton(
                buttonText: 'Save as Draft',
                leadingIcon: Icons.save_outlined,
                onPressed: () async {
                  final err = await context.read<PublishCubit>().saveDraft();
                  if (!context.mounted) return;
                  AppFeedback.show(
                    context,
                    title: err != null ? 'Could Not Save Draft' : 'Draft Saved',
                    message: err ?? 'Your project draft has been saved.',
                    type: err != null
                        ? AppFeedbackType.error
                        : AppFeedbackType.success,
                    fromTop: err != null,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );

    return embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Review & Publish')),
            body: body,
          );
  }
}

// Review section card with Edit action.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: c.textPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, style: AppStyles.body12Bold(context)),
              ),
              AppTextButton(onPressed: onEdit, buttonText: 'Edit'),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// Metadata pill badge.
class _MetaPill extends StatelessWidget {
  const _MetaPill(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.secondarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.primary),
          const SizedBox(width: 5),
          Text(label, style: AppStyles.body11SemiBold(context)),
        ],
      ),
    );
  }
}
