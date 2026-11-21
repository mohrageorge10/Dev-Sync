import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class _Project {
  final String title, desc, team;
  final List<String> skills;
  const _Project(this.title, this.desc, this.team, this.skills);
}

const _projects = [
  _Project('Offline-first Notes App', 'Sync-first mobile notes app. Looking for Flutter contributors.', '3 of 5 members', ['Flutter', 'Dart', 'REST APIs']),
  _Project('DevSync Mobile Companion', 'Companion app with push notifications and profile sync.', '2 of 4 members', ['Flutter', 'Firebase', 'Dart']),
  _Project('Open-source ML Toolkit', 'Reusable model-evaluation helpers for Python teams.', '4 of 6 members', ['Python', 'AI/ML', 'SQL']),
  _Project('Developer Portfolio Generator', 'Generate portfolio sites from a GitHub profile.', '2 of 3 members', ['React', 'Node.js', 'JavaScript']),
  _Project('Realtime Chat Backend', 'Scalable chat API with presence and typing indicators.', '3 of 5 members', ['Node.js', 'REST APIs', 'Firebase']),
];

class ExploreProjectsScreen extends StatefulWidget {
  const ExploreProjectsScreen({super.key});
  @override
  State<ExploreProjectsScreen> createState() => _ExploreProjectsScreenState();
}

class _ExploreProjectsScreenState extends State<ExploreProjectsScreen> {
  final Set<String> _requested = {};

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    final mine = c.allSkills.map((s) => s.toLowerCase()).toSet();
    final ranked = _projects.map((p) {
      final hits = p.skills.where((s) => mine.contains(s.toLowerCase())).length;
      return (p: p, match: (hits * 100 / p.skills.length).round());
    }).toList()
      ..sort((a, b) => b.match.compareTo(a.match));

    return AppScaffold(
      title: 'Explore Projects',
      actions: [IconButton(icon: const Icon(Icons.person_outline, size: 20), onPressed: () => Navigator.pushNamed(context, ProfileRoutes.snapshot))],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        screenTitle('Matched for you', 'Ranked by how well your verified skills fit each team.'),
        for (final r in ranked)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(r.p.title, style: ProfileStyles.sectionTitle)),
                  Tag('${r.match}% match', fg: r.match >= 60 ? ProfileColors.success : ProfileColors.textSecondary, bg: r.match >= 60 ? ProfileColors.successSoft : ProfileColors.surface),
                ]),
                const SizedBox(height: 4),
                Text(r.p.desc, style: ProfileStyles.bodySmallRelaxed),
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final s in r.p.skills)
                    Tag(s, fg: mine.contains(s.toLowerCase()) ? ProfileColors.primary : ProfileColors.textSecondary, bg: mine.contains(s.toLowerCase()) ? ProfileColors.subtleBlueSurface : ProfileColors.surface),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.group_outlined, size: 14, color: ProfileColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(r.p.team, style: ProfileStyles.caption)),
                  if (_requested.contains(r.p.title))
                    CompactButton('Requested', icon: Icons.check, filled: false, color: ProfileColors.success, onPressed: () => setState(() => _requested.remove(r.p.title)))
                  else
                    CompactButton('Request to join', onPressed: () {
                      setState(() => _requested.add(r.p.title));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('Request sent to ${r.p.title}'), behavior: SnackBarBehavior.floating));
                    }),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }
}
