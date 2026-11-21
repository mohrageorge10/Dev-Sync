import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../../data/models/detected_skill.dart';
import '../cubit/profile_controller.dart';
import 'github/disconnect_dialog.dart';

class DeveloperSnapshotScreen extends StatelessWidget {
  const DeveloperSnapshotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    final suggestions = c.pendingSuggestions;
    final extraVerified = c.verifiedSkills.where((s) => !c.languages.containsKey(s) && !c.frameworks.contains(s)).toList();

    return AppScaffold(
      title: 'Profile Details',
      footer: Row(children: [
        Expanded(child: SoftButton('Edit Profile', icon: Icons.edit_outlined, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.basicInfo))),
        const SizedBox(width: 10),
        Expanded(child: PrimaryButton('Explore Projects', icon: Icons.arrow_forward, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.explore))),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header
        AppCard(
          child: Column(children: [
            Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: ProfileColors.subtleBlueSurface,
                backgroundImage: c.avatarBytes == null ? null : MemoryImage(c.avatarBytes!),
                child: c.avatarBytes == null ? const Icon(Icons.person, color: ProfileColors.primary) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(c.displayName.isEmpty ? 'Your name' : c.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                    const SizedBox(width: 8),
                    if (c.level != null) Tag(c.level!.toUpperCase()),
                  ]),
                  Text(c.track == null ? 'Developer' : '${c.track} Developer', style: ProfileStyles.bodySmall),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: c.devSyncId));
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(content: Text('DevSync ID copied'), behavior: SnackBarBehavior.floating));
                    },
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(c.devSyncId, style: ProfileStyles.caption),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 10, color: ProfileColors.textSecondary),
                    ]),
                  ),
                ]),
              ),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ProfileColors.backgroundPrimary, borderRadius: BorderRadius.circular(10), border: Border.all(color: ProfileColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: ProfileColors.primary),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('Profile Completeness', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
                  Text('${c.completion}%', style: const TextStyle(fontWeight: FontWeight.w800, color: ProfileColors.primary, fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: c.completion / 100, minHeight: 5, backgroundColor: ProfileColors.border, color: ProfileColors.primary),
                ),
                const SizedBox(height: 6),
                Text(c.completion == 100 ? 'Ready for top project matches' : 'Almost ready for optimal project matching', style: ProfileStyles.caption),
              ]),
            ),
          ]),
        ),
        // ── Skills
        SectionLabel('Your Skills', trailing: c.verifiedSkills.isNotEmpty || c.githubConnected ? 'VERIFIED PROFILE' : null, icon: Icons.code),
        const _Mini('PROGRAMMING LANGUAGES'),
        _wrap([for (final l in c.languages.keys) AppSkillChip(label: l, selected: true)]),
        const _Mini('TECHNICAL STACK & TOOLS'),
        _wrap([for (final f in c.frameworks) AppSkillChip(label: f)]),
        const _Mini('COLLABORATION & SOFT SKILLS'),
        _wrap([for (final s in c.softSkills) AppSkillChip(label: s)]),
        if (extraVerified.isNotEmpty) ...[
          const _Mini('VERIFIED FROM GITHUB'),
          _wrap([for (final s in extraVerified) AppSkillChip(label: s, selected: true)]),
        ],
        // ── AI-detected
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 18),
          AppCard(
            color: ProfileColors.subtleBlueSurface,
            borderColor: Colors.transparent,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome, size: 15, color: ProfileColors.primary),
                const SizedBox(width: 6),
                const Expanded(child: Text('AI-Detected Skills', style: ProfileStyles.cardTitle)),
                Tag('${suggestions.length} Suggestions'),
              ]),
              const SizedBox(height: 4),
              const Text('Inferred from your technical selections. Accept to add them to your verified profile or reject.', style: TextStyle(fontSize: 10, color: ProfileColors.textSecondary, height: 1.3)),
              const SizedBox(height: 8),
              for (final s in suggestions) _SuggestionRow(skill: s, c: c),
            ]),
          ),
        ],
        // ── Credentials
        const SectionLabel('Credentials & Links', icon: Icons.link),
        if (c.resumeName != null)
          _LinkTile(
            icon: Icons.description_outlined,
            title: c.resumeName!,
            sub: 'Verified Attachment • ${formatBytes(c.resumeSize)}',
            verified: true,
            trailing: Icons.visibility_outlined,
            onTap: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Résumé'),
                content: Text('${c.resumeName}\n${formatBytes(c.resumeSize)} • PDF'),
                actions: [AppTextButton(onPressed: () => Navigator.pop(context), buttonText: 'Close')],
              ),
            ),
          ),
        if (c.portfolio.isNotEmpty) _LinkTile(icon: Icons.public, title: _host(c.portfolio), sub: 'PORTFOLIO', subFirst: true),
        if (c.linkedin.isNotEmpty) _LinkTile(icon: Icons.business_center_outlined, title: _host(c.linkedin), sub: 'LINKEDIN', subFirst: true),
        // ── Accounts
        const SectionLabel('CONNECTED ACCOUNTS'),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(children: [
            _Account(
              icon: const Icon(Icons.code, size: 18),
              name: 'GitHub',
              status: c.githubConnected ? '@${c.analysis?.username ?? 'connected'}' : 'Not connected',
              button: c.githubConnected
                  ? CompactButton('Disconnect', filled: false, color: ProfileColors.error, onPressed: () async {
                      if (await showDisconnectGithubDialog(context, keptSkills: c.verifiedSkills.length)) c.disconnectGithub();
                    })
                  : CompactButton('Connect', filled: false, onPressed: () => Navigator.pushNamed(context, ProfileRoutes.githubConnect)),
            ),
            const Divider(height: 1, color: ProfileColors.surface),
            _Account(
              icon: const Icon(Icons.palette_outlined, size: 18),
              name: 'Behance',
              status: 'Not connected',
              button: CompactButton('Connect', filled: false, onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Behance integration coming soon.'), behavior: SnackBarBehavior.floating));
              }),
            ),
          ]),
        ),
      ]),
    );
  }

  static String _host(String url) => url.replaceFirst(RegExp(r'^https?://(www\.)?'), '');

  Widget _wrap(List<Widget> kids) => kids.isEmpty
      ? const Padding(padding: EdgeInsets.only(bottom: 2), child: Text('—', style: TextStyle(color: ProfileColors.textSecondary)))
      : Wrap(spacing: 6, runSpacing: 6, children: kids);
}

class _Mini extends StatelessWidget {  final String t;
  const _Mini(this.t);
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: ProfileColors.textSecondary, letterSpacing: .5)));
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final bool verified, subFirst;
  final IconData trailing;
  final VoidCallback? onTap;
  const _LinkTile({required this.icon, required this.title, required this.sub, this.verified = false, this.subFirst = false, this.trailing = Icons.open_in_new, this.onTap});
  @override
  Widget build(BuildContext context) {
    final titleW = Row(children: [
      Flexible(child: Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11))),
      if (verified) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, size: 12, color: ProfileColors.primary)),
    ]);
    final subW = Text(sub, style: TextStyle(fontSize: subFirst ? 8 : 10, color: ProfileColors.textSecondary, letterSpacing: subFirst ? .6 : 0));
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: ProfileColors.subtleBlueSurface, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: ProfileColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: subFirst ? [subW, titleW] : [titleW, subW])),
            Icon(trailing, size: 15, color: ProfileColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}

class _Account extends StatelessWidget {
  final Widget icon, button;
  final String name, status;
  const _Account({required this.icon, required this.name, required this.status, required this.button});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: ProfileStyles.cardTitle),
              Text(status, style: ProfileStyles.caption),
            ]),
          ),
          button,
        ]),
      );
}

class _SuggestionRow extends StatelessWidget {
  final DetectedSkill skill;
  final ProfileController c;
  const _SuggestionRow({required this.skill, required this.c});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const CircleAvatar(radius: 3, backgroundColor: ProfileColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(skill.name, style: ProfileStyles.cardTitle),
              Text('Confidence: ${skill.confidence}', style: ProfileStyles.caption),
            ]),
          ),
          _RoundBtn(Icons.check, ProfileColors.primary, () => c.addDetected(skill)),
          const SizedBox(width: 6),
          _RoundBtn(Icons.close, ProfileColors.textSecondary, () => c.dismissDetected(skill)),
        ]),
      );
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RoundBtn(this.icon, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.1)),
          child: Icon(icon, size: 14, color: color),
        ),
      );
}
