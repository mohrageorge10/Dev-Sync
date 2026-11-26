import 'package:devsync/core/constants/app_images.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/screens/github/disconnect_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/delete_cv_dialog.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_compact_button.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

// Displays résumé, external links, and connected accounts on the profile overview.
class SnapshotCredentialsSection extends StatelessWidget {
  const SnapshotCredentialsSection({
    super.key,
    required this.profile,
    this.onProfileUpdated,
  });

  final ProfileController profile;
  final VoidCallback? onProfileUpdated;

  static const _maxCvBytes = 5 * 1024 * 1024;

  static String _host(String url) =>
      url.replaceFirst(RegExp(r'^https?://(www\.)?'), '');

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;
    final normalized = trimmed.startsWith(RegExp(r'https?://'))
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      AppFeedback.show(
        context,
        message: 'Could not open link.',
        type: AppFeedbackType.error,
      );
    }
  }

  Future<void> _uploadNewCv(BuildContext context) async {
    const pdf = XTypeGroup(
      label: 'PDF',
      extensions: ['pdf'],
      mimeTypes: ['application/pdf'],
    );
    final file = await openFile(acceptedTypeGroups: [pdf]);
    if (file == null) return;

    final size = await file.length();
    if (size > _maxCvBytes) {
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
      onProfileUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel('Credentials & Links', icon: Icons.link),
        if (profile.resumeName != null)
          _LinkTile(
            icon: Icons.description_outlined,
            title: profile.resumeName!,
            sub: profile.resumeSize > 0
                ? 'Verified Attachment • ${formatBytes(profile.resumeSize)}'
                : 'Verified Attachment • PDF',
            verified: true,
            trailingWidget: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert_rounded,
                size: 18,
                color: c.textSecondary,
              ),
              color: c.backgroundPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: c.border),
              ),
              onSelected: (value) async {
                if (value == 'edit') {
                  await _uploadNewCv(context);
                } else if (value == 'delete') {
                  final confirmed = await showDeleteCvDialog(context);
                  if (!confirmed || !context.mounted) return;
                  await profile.clearResume();
                  if (!context.mounted) return;
                  AppFeedback.show(
                    context,
                    message: 'CV removed.',
                    type: AppFeedbackType.info,
                  );
                  onProfileUpdated?.call();
                }
              },
              itemBuilder: (menuCtx) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 17, color: c.textPrimary),
                      const SizedBox(width: 8),
                      Text('Edit', style: AppStyles.body13Primary(menuCtx)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 17, color: c.error),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: AppStyles.body13Bold(menuCtx, color: c.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.profileCvViewer,
              arguments: (
                title: profile.resumeName!,
                url: profile.resumeUrl,
                bytes: profile.resumeBytes,
              ),
            ),
          )
        else
          _LinkTile(
            icon: Icons.upload_file_outlined,
            title: profile.isUploadingResume ? 'Uploading CV...' : 'Upload CV (PDF)',
            sub: 'Tap to attach your CV',
            trailing: Icons.add_rounded,
            onTap: profile.isUploadingResume
                ? null
                : () => _uploadNewCv(context),
          ),
        if (profile.portfolio.isNotEmpty)
          _LinkTile(
            icon: Icons.public,
            title: _host(profile.portfolio),
            sub: 'PORTFOLIO',
            subFirst: true,
            onTap: () => _openUrl(context, profile.portfolio),
          ),
        if (profile.linkedin.isNotEmpty)
          _LinkTile(
            icon: Icons.business_center_outlined,
            title: _host(profile.linkedin),
            sub: 'LINKEDIN',
            subFirst: true,
            onTap: () => _openUrl(context, profile.linkedin),
          ),
        if (profile.resumeName == null &&
            profile.portfolio.isEmpty &&
            profile.linkedin.isEmpty)
          Text(
            'No credentials added yet. Tap Edit Profile to add your résumé or links.',
            style: AppStyles.body12Secondary(context),
          ),
        const ProfileSectionLabel('Connected Accounts'),
        ProfileCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              _AccountRow(
                icon: SvgPicture.asset(
                  AppImages.githubLogo,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn),
                ),
                name: 'GitHub',
                status: profile.githubConnected
                    ? '@${profile.analysis?.username ?? 'connected'}'
                    : 'Not connected',
                button: profile.githubConnected
                    ? ProfileCompactButton(
                        'Disconnect',
                        color: c.error,
                        onPressed: () async {
                          final confirmed = await showDisconnectGithubDialog(
                            context,
                            keptSkills: profile.verifiedSkills.length,
                          );
                          if (confirmed) {
                            profile.disconnectGithub();
                            await profile.saveProfile();
                            onProfileUpdated?.call();
                          }
                        },
                      )
                    : ProfileCompactButton(
                        'Connect',
                        onPressed: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.profileGithubConnect,
                          );
                          onProfileUpdated?.call();
                        },
                      ),
              ),
              Divider(height: 1, color: c.surface),
              _AccountRow(
                icon: Icon(
                  Icons.palette_outlined,
                  size: 18,
                  color: c.textPrimary,
                ),
                name: 'Behance',
                status: 'Not connected',
                button: ProfileCompactButton(
                  'Connect',
                  onPressed: () => AppFeedback.show(
                    context,
                    message: 'Behance integration coming soon.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.sub,
    this.verified = false,
    this.subFirst = false,
    this.trailing = Icons.open_in_new,
    this.trailingWidget,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String sub;
  final bool verified;
  final bool subFirst;
  final IconData trailing;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final titleWidget = Row(
      children: [
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.body12Bold(context),
          ),
        ),
        if (verified)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(Icons.verified, size: 12, color: c.primary),
          ),
      ],
    );
    final subWidget = Text(
      sub,
      style: subFirst
          ? AppStyles.overline9Secondary(context, letterSpacing: 0.6)
          : AppStyles.caption10Secondary(context),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: ProfileCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: c.subtleBlueSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: c.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subFirst
                      ? [subWidget, titleWidget]
                      : [titleWidget, subWidget],
                ),
              ),
              trailingWidget ?? Icon(trailing, size: 15, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.name,
    required this.status,
    required this.button,
  });

  final Widget icon;
  final Widget button;
  final String name;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppStyles.body12Bold(context)),
                Text(status, style: AppStyles.caption10Secondary(context)),
              ],
            ),
          ),
          button,
        ],
      ),
    );
  }
}
