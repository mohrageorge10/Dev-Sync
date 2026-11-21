import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class SkillsExpertiseScreen extends StatefulWidget {
  const SkillsExpertiseScreen({super.key});

  @override
  State<SkillsExpertiseScreen> createState() => _SkillsExpertiseScreenState();
}

class _SkillsExpertiseScreenState extends State<SkillsExpertiseScreen> {
  late final TextEditingController _backgroundController;
  bool _initialized = false;

  static const soft = {
    'Adaptability': Icons.sync,
    'Communication': Icons.chat_bubble_outline,
    'Problem-solving': Icons.extension_outlined,
    'Leadership': Icons.emoji_objects_outlined,
    'Teamwork': Icons.groups_outlined,
    'Time Management': Icons.schedule,
  };
  static const domains = {
    'Mobile Apps': Icons.smartphone,
    'Web Development': Icons.language,
    'AI/ML': Icons.auto_awesome,
    'UI/UX': Icons.draw_outlined,
    'Open Source': Icons.public,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _backgroundController = TextEditingController(
      text: ProfileScope.of(context).background,
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    return AppScaffold(
      title: 'Skills And Expertise',
      footer: StepFooter(blockedReason: c.softBlockedReason, onContinue: () => Navigator.pushNamed(context, ProfileRoutes.projects)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StepProgress(60),
        const Text('How do you work best?', style: ProfileStyles.title),
        const SizedBox(height: 4),
        const Text('Collaborative projects succeed on communication and shared passions.', style: ProfileStyles.body),
        const SizedBox(height: 14),
        AppCard(
          color: ProfileColors.subtleBlueSurface,
          borderColor: Colors.transparent,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.hub_outlined, color: ProfileColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Team Synergy Engine', style: ProfileStyles.cardTitle),
                Text('Matches adapt automatically to align work habits, async rhythms, and collective drive.', style: ProfileStyles.bodySmall),
              ]),
            ),
          ]),
        ),
        SectionLabel('Soft Skills & Collaboration Style', trailing: '${c.softSkills.length} / ${ProfileController.maxSoftSkills}'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final e in soft.entries)
            SelectChip(e.key, icon: e.value, selected: c.softSkills.contains(e.key), onTap: () {
              if (!c.toggleSoft(e.key)) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('You can pick up to 4 core strengths.'), behavior: SnackBarBehavior.floating));
              }
            }),
        ]),
        const Padding(padding: EdgeInsets.only(top: 6), child: Text('Select up to 4 core strengths that define your teamwork.', style: ProfileStyles.caption)),
        const SectionLabel('Project Domains & Interests'),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final e in domains.entries) SelectChip(e.key, icon: e.value, selected: c.domains.contains(e.key), onTap: () => c.toggleDomain(e.key))]),
        const SizedBox(height: 18),
        const FieldLabel('Other technical background', trailing: 'Optional'),
        Column(children: [
            AppInputField(
              controller: _backgroundController,
              maxLines: 4,
              maxLength: 400,
              counterText: '',
              onChanged: c.setBackground,
              hint: 'Share bootcamps, certifications, university courses, hackathons, or past production work…',
            ),
            Row(children: [
              const Icon(Icons.lightbulb_outline, size: 12, color: ProfileColors.textSecondary),
              const SizedBox(width: 6),
              const Expanded(child: Text('Highlights your learning journey and context.', style: ProfileStyles.caption)),
              Text('${c.background.length}/400', style: ProfileStyles.caption),
            ]),
          ]),
      ]),
    );
  }
}
