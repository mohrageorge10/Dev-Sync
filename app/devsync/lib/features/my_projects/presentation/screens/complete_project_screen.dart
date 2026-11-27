import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/services/cloudinary/cloudinary_service.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/project_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/section_card.dart';

// Screen for closing/delivering a project or editing its shipped product showcase.
class CompleteProjectScreen extends StatefulWidget {
  const CompleteProjectScreen({super.key, required this.project});

  final ProjectModel project;

  @override
  State<CompleteProjectScreen> createState() => _CompleteProjectScreenState();
}

class _CompleteProjectScreenState extends State<CompleteProjectScreen> {
  late ProjectOutcome _outcome;
  late final TextEditingController _productUrlCtrl;
  late final TextEditingController _summaryCtrl;
  final TextEditingController _awardCtrl = TextEditingController();

  late String _logoUrl;
  late List<String> _awards;
  bool _uploadingLogo = false;
  bool _saving = false;

  bool get _isEditingPrevious => widget.project.type == ProjectType.previous;

  @override
  void initState() {
    super.initState();
    _outcome = widget.project.outcome ?? ProjectOutcome.completed;
    _logoUrl = widget.project.productLogoUrl;
    _productUrlCtrl = TextEditingController(text: widget.project.productUrl);
    _summaryCtrl = TextEditingController(
      text: widget.project.completionSummary,
    );
    _awards = List<String>.from(widget.project.awards);
  }

  @override
  void dispose() {
    _productUrlCtrl.dispose();
    _summaryCtrl.dispose();
    _awardCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
    if (_uploadingLogo) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();

      setState(() => _uploadingLogo = true);
      final cloudinary = ServiceLocator.get<CloudinaryService>();
      final url = await cloudinary.uploadProjectLogo(
        bytes: bytes,
        fileName: picked.name,
        projectId: widget.project.id,
      );
      if (!mounted) return;
      setState(() {
        _logoUrl = url;
        _uploadingLogo = false;
      });
      AppFeedback.show(
        context,
        message: 'Product logo uploaded',
        type: AppFeedbackType.success,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingLogo = false);
      AppFeedback.show(
        context,
        message: 'Failed to upload logo. Please try again.',
        type: AppFeedbackType.error,
      );
    }
  }

  void _addAward() {
    final text = _awardCtrl.text.trim();
    if (text.isEmpty) return;
    if (_awards.any((a) => a.toLowerCase() == text.toLowerCase())) {
      _awardCtrl.clear();
      return;
    }
    setState(() {
      _awards.add(text);
      _awardCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (_saving) return;
    final rawUrl = _productUrlCtrl.text.trim();
    if (rawUrl.isNotEmpty) {
      final normalized =
          rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
          ? rawUrl
          : 'https://$rawUrl';
      final uri = Uri.tryParse(normalized);
      if (uri == null || !uri.hasAuthority) {
        AppFeedback.show(
          context,
          message: 'Please enter a valid product URL',
          type: AppFeedbackType.error,
        );
        return;
      }
      _productUrlCtrl.text = normalized;
    }

    setState(() => _saving = true);
    await context.read<MyProjectsCubit>().completeProject(
      widget.project.id,
      outcome: _outcome,
      productLogoUrl: _logoUrl,
      productUrl: _productUrlCtrl.text.trim(),
      awards: _awards,
      completionSummary: _summaryCtrl.text.trim(),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: _isEditingPrevious
            ? 'Edit Product Showcase'
            : 'Complete Project',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Outcome',
                  style: AppStyles.title15Bold(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how "${widget.project.name}" concluded. It will move to Previous and close applications.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 12),
                _OutcomeOption(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Completed / Delivered',
                  subtitle: 'Finished milestones and delivered the project.',
                  selected: _outcome == ProjectOutcome.completed,
                  accentColor: c.success,
                  onTap: () =>
                      setState(() => _outcome = ProjectOutcome.completed),
                ),
                const SizedBox(height: 8),
                _OutcomeOption(
                  icon: Icons.rocket_launch_outlined,
                  title: 'Shipped as Live Product',
                  subtitle:
                      'Launched to real users with a logo, product link, or awards.',
                  selected: _outcome == ProjectOutcome.shipped,
                  accentColor: c.primary,
                  onTap: () =>
                      setState(() => _outcome = ProjectOutcome.shipped),
                ),
                const SizedBox(height: 8),
                _OutcomeOption(
                  icon: Icons.archive_outlined,
                  title: 'Archived',
                  subtitle: 'Pause or close the project for reference.',
                  selected: _outcome == ProjectOutcome.archived,
                  accentColor: c.textSecondary,
                  onTap: () =>
                      setState(() => _outcome = ProjectOutcome.archived),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Showcase (Optional)',
                  style: AppStyles.title15Bold(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Highlight your launched product with a logo and live link.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _uploadingLogo
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                ),
                              ),
                            )
                          : _logoUrl.isNotEmpty
                          ? Image.network(
                              _logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.broken_image_outlined,
                                color: c.textSecondary,
                              ),
                            )
                          : Icon(
                              Icons.rocket_launch_outlined,
                              size: 28,
                              color: c.primary,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Logo',
                            style: AppStyles.body14Bold(context),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'PNG or JPG displayed on your showcase card.',
                            style: AppStyles.body12Secondary(context),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _uploadingLogo
                                    ? null
                                    : _pickAndUploadLogo,
                                icon: const Icon(
                                  Icons.upload_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  _logoUrl.isEmpty
                                      ? 'Upload Logo'
                                      : 'Change Logo',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: c.primary,
                                  side: BorderSide(color: c.primary),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              if (_logoUrl.isNotEmpty)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _logoUrl = ''),
                                  child: Text(
                                    'Remove',
                                    style: AppStyles.body12Medium(
                                      context,
                                      color: c.error,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Live Product Link',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _productUrlCtrl,
                  keyboardType: TextInputType.url,
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText: 'https://your-product.com or store link',
                    hintStyle: AppStyles.body13Secondary(context),
                    prefixIcon: Icon(
                      Icons.link_rounded,
                      size: 18,
                      color: c.textSecondary,
                    ),
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Completion Summary',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _summaryCtrl,
                  maxLines: 3,
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Shipped v1.0 with 500+ active users and full offline sync.',
                    hintStyle: AppStyles.body13Secondary(context),
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: c.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 18,
                      color: c.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Awards & Achievements',
                      style: AppStyles.title15Bold(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Add hackathon wins, graduation honors, or recognition.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _awardCtrl,
                        style: AppStyles.body14Primary(context),
                        onSubmitted: (_) => _addAward(),
                        decoration: InputDecoration(
                          hintText: 'e.g. 1st Place — DEPI Showcase',
                          hintStyle: AppStyles.body13Secondary(context),
                          filled: true,
                          fillColor: c.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: c.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: c.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: c.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _addAward,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.primary,
                          foregroundColor: c.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                if (_awards.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _awards
                        .map(
                          (award) => InputChip(
                            avatar: Icon(
                              Icons.emoji_events_rounded,
                              size: 16,
                              color: c.warning,
                            ),
                            label: Text(
                              award,
                              style: AppStyles.body12Medium(
                                context,
                                color: c.textPrimary,
                              ),
                            ),
                            backgroundColor: c.subtle(c.warning),
                            side: BorderSide(
                              color: c.warning.withValues(alpha: 0.4),
                            ),
                            deleteIconColor: c.textSecondary,
                            onDeleted: () =>
                                setState(() => _awards.remove(award)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          AppButton(
            label: _saving
                ? 'Saving...'
                : _isEditingPrevious
                ? 'Save Showcase Changes'
                : 'Complete & Close Project',
            onPressed: _saving ? null : _submit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OutcomeOption extends StatelessWidget {
  const _OutcomeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.08) : c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : c.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? accentColor : c.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.body14Bold(
                      context,
                      color: selected ? accentColor : c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppStyles.body12Secondary(context)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 20, color: accentColor),
          ],
        ),
      ),
    );
  }
}
