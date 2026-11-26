import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/services/github_service.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Multi-step progress screen while analyzing a connected GitHub profile.
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _service = GithubService();
  int _step = 0;
  bool _failed = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _run();
    }
  }

  Future<void> _run() async {
    setState(() {
      _failed = false;
      _step = 0;
    });
    final profile = ProfileScope.of(context);
    try {
      final result = await _service.analyze(
        (i) {
          if (mounted) setState(() => _step = i);
        },
        username: profile.username,
      );
      if (!mounted) return;
      profile.setAnalysis(result);
      profile.markGithubConnected();
      await profile.saveProfile();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.profileGithubReview);
    } on GithubException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ProfileScaffold(
      title: 'Analysis In Progress',
      child: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: _failed ? 0.0 : null,
                  strokeWidth: 6,
                  color: c.primary,
                  backgroundColor: c.subtleBlueSurface,
                ),
              ),
              SvgPicture.asset(
                AppImages.githubLogo,
                width: 36,
                height: 36,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Analyzing your work', style: AppStyles.h2(context)),
          const SizedBox(height: 6),
          Text(
            "This usually takes a few seconds. We're assembling your verified tech profile.",
            textAlign: TextAlign.center,
            style: AppStyles.body13Secondary(context),
          ),
          const SizedBox(height: 20),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PIPELINE PROGRESS',
                        style: AppStyles.caption10Bold(
                          context,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'Step ${_step + 1} of 4',
                      style: AppStyles.body11Bold(context, color: c.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < 4; i++)
                  _PipelineRow(index: i, current: _step, failed: _failed),
              ],
            ),
          ),
          if (_failed) ...[
            const SizedBox(height: 18),
            ProfileCard(
              color: c.subtleBlueSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync_problem, color: c.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connection Interrupted',
                          style: AppStyles.body13Bold(context),
                        ),
                      ),
                      ProfileTag('FALLBACK', fg: c.error, bg: c.subtle(c.error)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Couldn't reach GitHub. You can continue with your manual profile setup or reattempt sync.",
                    style: AppStyles.body12Secondary(context),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileSoftButton(
                          'Retry',
                          icon: Icons.refresh,
                          onPressed: _run,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ProfilePrimaryButton(
                          'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.index,
    required this.current,
    required this.failed,
  });

  final int index;
  final int current;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = index < current;
    final running = index == current && !failed;
    final broken = index == current && failed;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: running ? c.subtleBlueSurface : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            done
                ? Icons.check_circle
                : broken
                ? Icons.error
                : running
                ? Icons.autorenew
                : Icons.radio_button_unchecked,
            size: 20,
            color: done
                ? c.success
                : broken
                ? c.error
                : running
                ? c.primary
                : c.border,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GithubService.stepTitles[index],
                  style: AppStyles.body12Bold(
                    context,
                    color: (done || running || broken)
                        ? c.textPrimary
                        : c.textSecondary,
                  ),
                ),
                Text(
                  GithubService.stepHints[index],
                  style: AppStyles.body11Medium(
                    context,
                    color: running ? c.primary : c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (done) ProfileTag('Done', fg: c.success, bg: c.subtle(c.success)),
          if (running) const ProfileTag('Running'),
        ],
      ),
    );
  }
}
