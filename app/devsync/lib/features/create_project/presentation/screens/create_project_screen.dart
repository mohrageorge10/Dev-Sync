import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/screens/launch_success.dart';
import 'package:devsync/features/create_project/presentation/screens/project_details.dart';
import 'package:devsync/features/create_project/presentation/screens/review_publish.dart';
import 'package:devsync/features/create_project/presentation/screens/team_formation.dart';
import 'package:devsync/features/create_project/presentation/widgets/project_strength_meter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Main wizard screen for creating a project.
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _pageController = PageController();
  int _step = 0;

  static const _titles = [
    'Project Details',
    'Team Formation',
    'Review & Publish',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Navigate to wizard step.
  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  // Validate step jump.
  bool _canJumpTo(int target) {
    if (target <= _step) return true;
    final draftValid = context.read<DraftCubit>().state.draft.isValid;
    final hasTracks = context.read<TeamCubit>().state.tracks.isNotEmpty;
    return target == 1 ? draftValid : (draftValid && hasTracks);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isPublished = context.watch<PublishCubit>().state is PublishSuccess;

    return BlocListener<PublishCubit, PublishState>(
      listener: (context, state) {
        if (state is PublishFailure) {
          AppFeedback.show(
            context,
            title: 'Publish Failed',
            message: state.message,
            type: AppFeedbackType.error,
            fromTop: true,
          );
        } else if (state is PublishInitial && _step != 0) {
          _goToStep(0);
        }
      },
      child: PopScope(
        canPop: !isPublished && _step == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          isPublished ? Navigator.of(context).pop() : _goToStep(_step - 1);
        },
        child: Scaffold(
          appBar: isPublished
              ? null
              : AppBar(
                  backgroundColor: c.backgroundPrimary,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: c.textPrimary),
                    onPressed: () => _step > 0
                        ? _goToStep(_step - 1)
                        : Navigator.of(context).maybePop(),
                  ),
                  title: Column(
                    children: [
                      Text(
                        _titles[_step],
                        style: AppStyles.title16Bold(context),
                      ),
                      Text(
                        'Step ${_step + 1} of 3',
                        style: AppStyles.body11Secondary(context),
                      ),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: _StepBar(
                      currentStep: _step,
                      onTap: (i) => _canJumpTo(i)
                          ? _goToStep(i)
                          : AppFeedback.show(
                              context,
                              title: 'Complete Current Step',
                              message: i == 1
                                  ? 'Enter a valid title and description first.'
                                  : 'Add at least one open track first.',
                              type: AppFeedbackType.warning,
                              fromTop: true,
                            ),
                    ),
                  ),
                ),
          body: isPublished
              ? LaunchSuccessScreen(
                  embedded: true,
                  onDone: () => Navigator.of(context).maybePop(),
                )
              : Column(
                  children: [
                    // Pinned project strength meter.
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: c.backgroundPrimary,
                        border: Border(bottom: BorderSide(color: c.border)),
                      ),
                      child: const ProjectStrengthMeter(),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          ProjectDetailsScreen(
                            embedded: true,
                            onNext: () => _goToStep(1),
                          ),
                          TeamFormationScreen(
                            embedded: true,
                            onBack: () => _goToStep(0),
                            onNext: () => _goToStep(2),
                          ),
                          ReviewPublishScreen(
                            embedded: true,
                            onBack: () => _goToStep(1),
                            onEditDetails: () => _goToStep(0),
                            onEditTeam: () => _goToStep(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Top wizard step indicator bar.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.currentStep, required this.onTap});

  final int currentStep;
  final ValueChanged<int> onTap;
  static const _labels = ['1. Details', '2. Team', '3. Review'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        spacing: 8,
        children: [
          for (int i = 0; i < _labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= currentStep ? c.primary : c.border,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[i],
                      style: i == currentStep
                          ? AppStyles.body11Bold(context, color: c.primary)
                          : AppStyles.body11Medium(
                              context,
                              color: i < currentStep
                                  ? c.primary
                                  : c.textSecondary,
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
