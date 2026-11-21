import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class ProjectInterestsScreen extends StatelessWidget {
  const ProjectInterestsScreen({super.key});
  static const _maxBytes = 5 * 1024 * 1024;

  Future<void> _pickResume(BuildContext context, ProfileController c) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      const pdf = XTypeGroup(label: 'PDF', extensions: ['pdf'], mimeTypes: ['application/pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [pdf]);
      if (file == null) return; // المستخدم لغى

      final size = await file.length();
      if (size > _maxBytes) {
        messenger.showSnackBar(const SnackBar(
          content: Text('File is too large. Max size is 5 MB.'),
          behavior: SnackBarBehavior.floating,
        ));
        return;
      }

      final bytes = await file.readAsBytes();
      c.setResume(file.name, size: size, bytes: bytes);
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Couldn\'t open the file picker: $e'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    return AppScaffold(
      title: 'Project Interests',
      footer: StepFooter(blockedReason: c.resumeBlockedReason, onContinue: () => Navigator.pushNamed(context, ProfileRoutes.connectWork)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StepProgress(80),
        const Text('Show your work', style: ProfileStyles.title),
        const SizedBox(height: 4),
        const Text('Attach your résumé and external links so project leads can review your credentials.', style: ProfileStyles.subtitle),
        const SizedBox(height: 18),
        Row(children: const [
          Expanded(child: Text('CV / Résumé', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
          Text('REQUIRED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: ProfileColors.primary)),
        ]),
        const SizedBox(height: 8),
        if (c.resumeName != null)
          AppCard(
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ProfileColors.subtleBlueSurface, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.description_outlined, color: ProfileColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(c.resumeName!, overflow: TextOverflow.ellipsis, style: ProfileStyles.cardTitle)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 13, color: ProfileColors.success),
                  ]),
                  Text('${formatBytes(c.resumeSize)} • PDF • Uploaded just now', style: ProfileStyles.caption),
                ]),
              ),
              IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete_outline, color: ProfileColors.error, size: 18), onPressed: () => c.setResume(null)),
            ]),
          ),
        if (c.resumeName != null) const SizedBox(height: 10),
        DashedBox(
          onTap: () => _pickResume(context, c),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: ProfileColors.subtleBlueSurface, shape: BoxShape.circle),
              child: const Icon(Icons.cloud_upload_outlined, color: ProfileColors.primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(c.resumeName == null ? 'Upload PDF (max 5 MB)' : 'Replace PDF (max 5 MB)', style: ProfileStyles.cardTitle),
            const Text('Drag or tap to browse files', style: ProfileStyles.caption),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('ONLINE PRESENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: ProfileColors.textSecondary, letterSpacing: .5)),
        const SizedBox(height: 10),
        _field('Portfolio / Personal Website', null, Icons.public, c.portfolio, 'https://alexmorgan.dev', (v) => c.setLinks(portfolioUrl: v)),
        _field('LinkedIn Profile', null, Icons.link, c.linkedin, 'https://linkedin.com/in/alexmorgan', (v) => c.setLinks(linkedinUrl: v)),
        _field('GitHub / GitLab', 'Optional', Icons.code, c.githubUrl, 'https://github.com/alexmorgan', (v) => c.setLinks(github: v)),
      ]),
    );
  }

  Widget _field(String label, String? trailing, IconData icon, String value, String hint, ValueChanged<String> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FieldLabel(label, trailing: trailing),
          TextFormField(
            initialValue: value,
            keyboardType: TextInputType.url,
            onChanged: onChanged,
            style: ProfileStyles.input,
            decoration: fieldDeco(prefixIcon: Icon(icon, size: 18, color: ProfileColors.textSecondary), hintText: hint),
          ),
        ]),
      );
}
