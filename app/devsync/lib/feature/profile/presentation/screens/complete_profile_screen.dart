import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  /// Where each unfinished item sends the user.
  static const _targets = {
    'Basic Info': ProfileRoutes.basicInfo,
    'Track & Experience Level': ProfileRoutes.technical,
    'Languages & Frameworks': ProfileRoutes.technical,
    'Soft Skills & Interests': ProfileRoutes.skills,
    'Curriculum Vitae / Résumé': ProfileRoutes.projects,
    'Portfolio Link': ProfileRoutes.projects,
    'LinkedIn Link': ProfileRoutes.projects,
    'GitHub Connection': ProfileRoutes.githubConnect,
  };

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    final items = c.checklist;
    final done = c.completion == 100;
    final missing = items.length - c.completedItems;

    return AppScaffold(
      title: 'Complete your profile',
      actions: [IconButton(icon: const Icon(Icons.help_outline, size: 20, color: ProfileColors.textSecondary), onPressed: () => _help(context))],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header card with ring
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Colors.white, ProfileColors.subtleBlueSurface], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: ProfileColors.border),
          ),
          child: Column(children: [
            const Text('A complete profile gives you more accurate project matches.', textAlign: TextAlign.center, style: ProfileStyles.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              width: 112,
              height: 112,
              child: Stack(alignment: Alignment.center, children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(value: c.completion / 100, strokeWidth: 9, color: ProfileColors.primary, backgroundColor: ProfileColors.border),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${c.completion}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  const Text('COMPLETED', style: TextStyle(fontSize: 8, letterSpacing: 1, color: ProfileColors.textSecondary)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ProfileColors.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(done ? Icons.verified : Icons.add_task, size: 13, color: done ? ProfileColors.success : ProfileColors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(done ? 'Top Match status unlocked' : 'Add $missing more item${missing == 1 ? '' : 's'} to unlock Top Match status',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ProfileColors.primary)),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        // ── Checklist
        Row(children: [
          const Text('Verification Checklist', style: ProfileStyles.cardTitleLarge),
          const SizedBox(width: 8),
          Tag('${c.completedItems} of ${items.length}'),
          const Spacer(),
          const Text('STEP 2 OF 3', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: ProfileColors.primary)),
        ]),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: ProfileColors.surface),
              _Row(item: items[i], onAdd: () => Navigator.pushNamed(context, _targets[items[i].title]!)),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        // ── Boost card (<100%) or success card (100%)
        if (!done)
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, color: ProfileColors.primary, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('Boost Match Relevance', style: ProfileStyles.cardTitle)),
              ]),
              const SizedBox(height: 4),
              Text('Your profile is ${c.completion}% complete. Finish it for better matches.', style: const TextStyle(fontSize: 11, color: ProfileColors.textSecondary, height: 1.3)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: c.completion / 100, minHeight: 4, backgroundColor: ProfileColors.border, color: ProfileColors.primary),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: Text('$missing step${missing == 1 ? '' : 's'} remaining', style: ProfileStyles.caption)),
                CompactButton('Complete Profile', onPressed: () {
                  final first = items.firstWhere((e) => !e.done).title;
                  Navigator.pushNamed(context, _targets[first]!);
                }),
              ]),
            ]),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Colors.white, ProfileColors.subtleBlueSurface], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: ProfileColors.border),
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: ProfileColors.successSoft, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.verified_user, color: ProfileColors.success, size: 24),
              ),
              const SizedBox(height: 8),
              const Tag('Top Match Unlocked', fg: ProfileColors.success, bg: ProfileColors.successSoft),
              const SizedBox(height: 10),
              const Text('Your profile is 100% complete!', textAlign: TextAlign.center, style: ProfileStyles.heading),
              const SizedBox(height: 4),
              const Text('You are now ready for precision AI team matching and high-priority project recommendations.',
                  textAlign: TextAlign.center, style: ProfileStyles.bodySmallRelaxed),
              const SizedBox(height: 14),
              PrimaryButton('Explore Projects', icon: Icons.explore_outlined, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.explore)),
              AppTextButton(onPressed: () => Navigator.pushNamed(context, ProfileRoutes.snapshot), buttonText: 'View Public Dev Profile'),
            ]),
          ),
        if (!done)
          Center(child: AppTextButton(onPressed: () => Navigator.pushNamed(context, ProfileRoutes.snapshot), buttonText: 'View my profile')),
      ]),
    );
  }

  void _help(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Why complete your profile?'),
          content: const Text('Each completed item gives the matching engine more evidence about your skills, so you get more accurate project and team recommendations.'),
          actions: [AppTextButton(onPressed: () => Navigator.pop(context), buttonText: 'Got it')],
        ),
      );
}

class _Row extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onAdd;
  const _Row({required this.item, required this.onAdd});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(shape: BoxShape.circle, color: item.done ? ProfileColors.success : null, border: item.done ? null : Border.all(color: ProfileColors.border, width: 1.5)),
            child: item.done ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: ProfileStyles.caption),
            ]),
          ),
          const SizedBox(width: 8),
          if (item.done) const Tag('Completed', fg: ProfileColors.success, bg: ProfileColors.successSoft) else CompactButton('+ Add', filled: false, onPressed: onAdd),
        ]),
      );
}
