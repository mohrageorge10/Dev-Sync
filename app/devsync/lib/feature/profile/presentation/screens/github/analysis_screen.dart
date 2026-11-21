import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../../widgets/profile_widgets.dart';
import '../../cubit/profile_controller.dart';
import '../../../data/services/github_service.dart';

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
    final c = ProfileScope.of(context);
    try {
      final result = await _service.analyze((i) {
        if (mounted) setState(() => _step = i);
      });
      if (!mounted) return;
      c.setAnalysis(result);
      c.markGithubConnected();
      Navigator.pushReplacementNamed(context, ProfileRoutes.githubReview);
    } on GithubException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Analysis In Progress',
      child: Column(children: [
        const SizedBox(height: 24),
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: _failed ? 0.0 : null,
              strokeWidth: 6,
              color: ProfileColors.primary,
              backgroundColor: ProfileColors.subtleBlueSurface,
            ),
          ),
          const Icon(Icons.hub_outlined, color: ProfileColors.primary, size: 30),
        ]),
        const SizedBox(height: 18),
        const Text('Analyzing your work', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('This usually takes a few seconds. We\'re assembling your verified tech profile.',
            textAlign: TextAlign.center, style: ProfileStyles.subtitle),
        const SizedBox(height: 20),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('PIPELINE PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ProfileColors.textSecondary))),
              Text('Step ${_step + 1} of 4', style: const TextStyle(fontSize: 11, color: ProfileColors.primary, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),
            for (var i = 0; i < 4; i++) _PipelineRow(index: i, current: _step, failed: _failed),
          ]),
        ),
        if (_failed) ...[
          const SizedBox(height: 18),
          AppCard(
            color: ProfileColors.subtleBlueSurface,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.sync_problem, color: ProfileColors.error, size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Connection Interrupted', style: ProfileStyles.cardTitleLarge)),
                const Tag('FALLBACK', fg: ProfileColors.error, bg: ProfileColors.errorSoft),
              ]),
              const SizedBox(height: 6),
              const Text('Couldn\'t reach GitHub. You can continue with your manual profile setup or reattempt sync.',
                  style: ProfileStyles.bodySmallRelaxed),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: SoftButton('Retry', icon: Icons.refresh, onPressed: _run)),
                const SizedBox(width: 10),
                Expanded(child: PrimaryButton('Continue', icon: Icons.arrow_forward, onPressed: () => Navigator.pop(context))),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  final int index, current;
  final bool failed;
  const _PipelineRow({required this.index, required this.current, required this.failed});
  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final running = index == current && !failed;
    final broken = index == current && failed;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: running ? ProfileColors.subtleBlueSurface : null, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(done ? Icons.check_circle : broken ? Icons.error : running ? Icons.autorenew : Icons.radio_button_unchecked,
            size: 20, color: done ? ProfileColors.success : broken ? ProfileColors.error : running ? ProfileColors.primary : ProfileColors.border),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(GithubService.stepTitles[index],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: (done || running || broken) ? ProfileColors.textPrimary : ProfileColors.textSecondary)),
            Text(GithubService.stepHints[index], style: TextStyle(fontSize: 11, color: running ? ProfileColors.primary : ProfileColors.textSecondary)),
          ]),
        ),
        if (done) const Tag('Done', fg: ProfileColors.success, bg: ProfileColors.successSoft),
        if (running) const Tag('Running'),
      ]),
    );
  }
}
