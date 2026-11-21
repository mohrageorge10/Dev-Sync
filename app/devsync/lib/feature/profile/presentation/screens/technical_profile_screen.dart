import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class TechnicalProfileScreen extends StatelessWidget {
  const TechnicalProfileScreen({super.key});
  static const tracks = ['Frontend', 'Backend', 'Full-stack', 'Mobile', 'AI/ML', 'Data', 'UI/UX', 'QA', 'DevOps'];
  static const langs = ['Kotlin', 'Dart', 'C++', 'Python', 'SQL', 'JavaScript', 'Java'];
  static const frameworks = ['Firebase', 'Flutter', 'REST APIs', 'React', 'Git/GitHub', 'Node.js', 'Figma'];

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    return AppScaffold(
      title: 'Account Type',
      footer: StepFooter(blockedReason: c.technicalBlockedReason, onContinue: () => Navigator.pushNamed(context, ProfileRoutes.skills)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StepProgress(40),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Expanded(child: Text('What\'s your technical profile?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15))),
          Container(
            margin: const EdgeInsets.only(left: 8, top: 2),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(color: ProfileColors.primary), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.code, size: 14, color: ProfileColors.primary),
          ),
        ]),
        const SizedBox(height: 6),
        const Text('Select your primary engineering discipline, experience level, and core toolset to match with ideal projects.',
            style: ProfileStyles.subtitle),
        const SectionLabel('Main Engineering Track', trailing: 'Single select', trailingColor: ProfileColors.textSecondary, icon: Icons.layers_outlined),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: [for (final t in tracks) SelectChip(t, pill: false, showCheck: false, selected: c.track == t, expand: true, onTap: () => c.setTrack(t))],
        ),
        const SectionLabel('Experience Level', icon: Icons.trending_up),
        SegmentedBar(items: ProfileController.levels, selected: c.level, onChanged: c.setLevel),
        SectionLabel('Programming Languages', trailing: '${c.languages.length} selected', icon: Icons.terminal),
        Wrap(spacing: 8, runSpacing: 10, children: [for (final l in langs) SelectChip(l, selected: c.languages.containsKey(l), onTap: () => c.toggleLanguage(l))]),
        if (c.languages.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: ProfileColors.subtleBlueSurface, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Expanded(child: Text('LANGUAGE PROFICIENCY SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ProfileColors.textSecondary, letterSpacing: .4))),
                Text('Tap to modify', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ProfileColors.primary)),
              ]),
              const SizedBox(height: 10),
              for (final e in c.languages.entries)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.only(left: 12, right: 8, top: 4, bottom: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: ProfileColors.primary)),
                    const Text('  •  ', style: TextStyle(color: ProfileColors.textSecondary, fontSize: 11)),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: e.value,
                        isDense: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: ProfileStyles.body,
                        items: ProfileController.levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (v) => c.setProficiency(e.key, v!),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(onTap: () => c.toggleLanguage(e.key), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 14, color: ProfileColors.textPrimary))),
                  ]),
                ),
            ]),
          ),
        ],
        const SectionLabel('Frameworks & Technical Skills', icon: Icons.layers_outlined),
        Wrap(spacing: 8, runSpacing: 10, children: [
          for (final f in {...frameworks, ...c.customSkills}) SelectChip(f, selected: c.frameworks.contains(f), onTap: () => c.toggleFramework(f)),
        ]),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: AppTextButton(
            onPressed: () => _addCustom(context, c),
            leadingIcon: Icons.add_circle_outline,
            buttonText: '+ Add custom skill',
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          color: ProfileColors.subtleBlueSurface,
          borderColor: Colors.transparent,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ProfileColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Curated Match Preview', style: ProfileStyles.cardTitle),
                Text(c.frameworks.isEmpty ? 'Pick your stack to see matching teams.' : 'Over 24 team projects currently looking for ${c.frameworks.take(2).join(' + ')} contributors!',
                    style: ProfileStyles.bodySmall),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  void _addCustom(BuildContext context, ProfileController c) {
    final t = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add custom skill'),
        content: TextField(controller: t, autofocus: true, decoration: fieldDeco(hintText: 'e.g. GraphQL')),
        actions: [
          AppTextButton(onPressed: () => Navigator.pop(context), buttonText: 'Cancel'),
          AppPrimaryButton(onPressed: () { c.addCustomSkill(t.text); Navigator.pop(context); }, buttonText: 'Add'),
        ],
      ),
    );
  }
}
