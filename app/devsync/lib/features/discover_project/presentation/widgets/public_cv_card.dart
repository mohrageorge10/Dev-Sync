import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/profile/presentation/screens/cv_viewer_screen.dart';
import 'package:flutter/material.dart';

// Read-only CV / Resume preview card on the public developer profile screen.
class PublicCvCard extends StatelessWidget {
  const PublicCvCard({super.key, required this.developer});

  final DeveloperModel developer;

  void _openCv(BuildContext context) {
    final url = developer.cvUrl;
    if (url == null || url.trim().isEmpty) return;
    final title = developer.cvFileName?.trim().isNotEmpty == true
        ? developer.cvFileName!.trim()
        : '${developer.name} - CV.pdf';
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) =>
            CvViewerScreen(title: title, url: url, allowManage: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasCv = developer.hasCv;
    final fileName = developer.cvFileName?.trim().isNotEmpty == true
        ? developer.cvFileName!.trim()
        : '${developer.name.replaceAll(' ', '_')}_CV.pdf';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasCv ? () => _openCv(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.backgroundPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasCv ? c.subtleBlueSurface : c.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: hasCv ? c.primary : c.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCv ? fileName : 'No CV uploaded yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: hasCv
                          ? AppStyles.body14Bold(context)
                          : AppStyles.body13Secondary(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasCv
                          ? 'Tap to view resume in-app'
                          : 'This developer has not attached a resume',
                      style: AppStyles.body12Secondary(context),
                    ),
                  ],
                ),
              ),
              if (hasCv) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.visibility_outlined,
                  color: c.primary,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
