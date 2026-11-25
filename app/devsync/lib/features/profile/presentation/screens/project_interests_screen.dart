import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/delete_cv_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_dashed_box.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_decoration.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_footer.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_progress.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

// Step 4 of profile setup: PDF résumé upload and online presence links.
class ProjectInterestsScreen extends StatelessWidget {
  const ProjectInterestsScreen({super.key});

  static const _maxBytes = 5 * 1024 * 1024;

  Future<void> _pickResume(
    BuildContext context,
    ProfileController profile,
  ) async {
    try {
      const pdf = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
      );
      final file = await openFile(acceptedTypeGroups: [pdf]);
      if (file == null) return;

      final size = await file.length();
      if (size > _maxBytes) {
        if (!context.mounted) return;
        AppFeedback.show(
          context,
          message: 'File is too large. Max size is 5 MB.',
          type: AppFeedbackType.warning,
        );
        return;
      }

      final bytes = await file.readAsBytes();
      final error = await profile.uploadResume(
        name: file.name,
        size: size,
        bytes: bytes,
      );
      if (!context.mounted) return;
      if (error != null) {
        AppFeedback.show(context, message: error, type: AppFeedbackType.error);
      } else {
        AppFeedback.show(
          context,
          message: 'CV uploaded successfully.',
          type: AppFeedbackType.success,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppFeedback.show(
        context,
        message: "Couldn't open the file picker: $e",
        type: AppFeedbackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'Credentials & Links',
      footer: ProfileStepFooter(
        blockedReason: profile.resumeBlockedReason,
        onContinue: () async {
          await profile.saveProfile();
          if (!context.mounted) return;
          Navigator.pushNamed(context, AppRoutes.profileConnectWork);
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStepProgress(80),
          Text('Show your work', style: AppStyles.h28(context)),
          const SizedBox(height: 4),
          Text(
            'Attach your CV and external links so project leads can review your credentials.',
            style: AppStyles.body13Secondary(context),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('CV', style: AppStyles.body12Bold(context))),
              Text('REQUIRED', style: AppStyles.overline9Bold(context)),
            ],
          ),
          const SizedBox(height: 8),
          if (profile.resumeName != null) ...[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.profileCvViewer,
                arguments: (
                  title: profile.resumeName!,
                  url: profile.resumeUrl,
                  bytes: profile.resumeBytes,
                ),
              ),
              child: ProfileCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: c.primary,
                        size: 18,
                      ),
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
                                  profile.resumeName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.body12Bold(context),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.verified, size: 13, color: c.success),
                            ],
                          ),
                          Text(
                            '${formatBytes(profile.resumeSize)} • PDF • Tap to preview',
                            style: AppStyles.caption10Secondary(context),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline,
                        color: c.error,
                        size: 18,
                      ),
                      onPressed: () async {
                        final confirmed = await showDeleteCvDialog(context);
                        if (confirmed) await profile.clearResume();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ProfileDashedBox(
            onTap: profile.isUploadingResume
                ? null
                : () => _pickResume(context, profile),
            child: profile.isUploadingResume
                ? Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: c.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Uploading CV...',
                        style: AppStyles.body12Bold(context),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c.subtleBlueSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          color: c.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.resumeName == null
                            ? 'Upload PDF (max 5 MB)'
                            : 'Replace PDF (max 5 MB)',
                        style: AppStyles.body12Bold(context),
                      ),
                      Text(
                        'Tap to browse files',
                        style: AppStyles.caption10Secondary(context),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          Text(
            'ONLINE PRESENCE',
            style: AppStyles.caption10Bold(
              context,
              color: c.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _LinkField(
            label: 'Portfolio / Personal Website',
            trailing: 'Optional',
            icon: Icons.public,
            value: profile.portfolio,
            hint: 'https://alexmorgan.dev',
            onChanged: (v) => profile.setLinks(portfolioUrl: v),
          ),
          _LinkField(
            label: 'LinkedIn Profile',
            trailing: 'Required',
            icon: Icons.link,
            value: profile.linkedin,
            hint: 'https://linkedin.com/in/alexmorgan',
            onChanged: (v) => profile.setLinks(linkedinUrl: v),
          ),
        ],
      ),
    );
  }
}

class _LinkField extends StatelessWidget {
  const _LinkField({
    required this.label,
    required this.icon,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final String? trailing;
  final IconData icon;
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileFieldLabel(label, trailing: trailing),
          TextFormField(
            initialValue: value,
            keyboardType: TextInputType.url,
            onChanged: onChanged,
            style: AppStyles.inputText(context),
            decoration: profileFieldDecoration(
              context,
              prefixIcon: Icon(icon, size: 18, color: c.textSecondary),
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}
