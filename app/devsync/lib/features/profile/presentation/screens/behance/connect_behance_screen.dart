import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/services/cloudinary/cloudinary_service.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/data/model/behance_profile.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_card.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Screen for connecting a Behance handle, design tools, and featured case studies.
class ConnectBehanceScreen extends StatefulWidget {
  const ConnectBehanceScreen({super.key});

  @override
  State<ConnectBehanceScreen> createState() => _ConnectBehanceScreenState();
}

class _ConnectBehanceScreenState extends State<ConnectBehanceScreen> {
  static const _availableTools = [
    'Figma',
    'Adobe XD',
    'Photoshop',
    'Illustrator',
    'Framer',
    'After Effects',
    'Prototyping',
    'Design Systems',
    'Wireframing',
    'User Research',
  ];

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _shotTitleCtrl = TextEditingController();
  final TextEditingController _shotUrlCtrl = TextEditingController();

  final Set<String> _selectedTools = {};
  final List<BehanceShot> _shots = [];
  String _pendingCoverUrl = '';
  bool _uploadingCover = false;
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final existing = ProfileScope.of(context).behanceProfile;
      if (existing != null) {
        _usernameCtrl.text = existing.username;
        _selectedTools.addAll(existing.tools);
        _shots.addAll(existing.shots);
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _shotTitleCtrl.dispose();
    _shotUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickShotCover() async {
    if (_uploadingCover) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _uploadingCover = true);
      final url = await ServiceLocator.get<CloudinaryService>()
          .uploadProjectLogo(bytes: bytes, fileName: picked.name);
      if (!mounted) return;
      setState(() {
        _pendingCoverUrl = url;
        _uploadingCover = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingCover = false);
      AppFeedback.show(
        context,
        message: 'Failed to upload cover image.',
        type: AppFeedbackType.error,
      );
    }
  }

  void _addShot() {
    final title = _shotTitleCtrl.text.trim();
    if (title.isEmpty) {
      AppFeedback.show(
        context,
        message: 'Enter a case study title first',
        type: AppFeedbackType.warning,
      );
      return;
    }
    var url = _shotUrlCtrl.text.trim();
    if (url.isNotEmpty &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }
    setState(() {
      _shots.add(
        BehanceShot(title: title, url: url, coverUrl: _pendingCoverUrl),
      );
      _shotTitleCtrl.clear();
      _shotUrlCtrl.clear();
      _pendingCoverUrl = '';
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final handle = BehanceProfile.extractUsername(_usernameCtrl.text);
    if (handle.isEmpty) return;

    setState(() => _saving = true);
    final profile = ProfileScope.of(context);
    profile.setBehanceProfile(
      BehanceProfile(
        username: handle,
        tools: _selectedTools.toList(),
        shots: List<BehanceShot>.from(_shots),
      ),
    );
    await profile.saveProfile();
    if (!mounted) return;
    AppFeedback.show(
      context,
      message: 'Behance portfolio connected',
      type: AppFeedbackType.success,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasUsername =
        BehanceProfile.extractUsername(_usernameCtrl.text).isNotEmpty;

    return ProfileScaffold(
      title: 'Connect Behance',
      footer: ProfilePrimaryButton(
        _saving ? 'Saving...' : 'Save Behance Portfolio',
        icon: Icons.palette_outlined,
        onPressed: (hasUsername && !_saving) ? _save : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'Bē',
                    style: AppStyles.h20(context).copyWith(color: c.onPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Connect your Behance', style: AppStyles.h28(context)),
                const SizedBox(height: 6),
                Text(
                  'Showcase your UI/UX portfolio, design tools, and featured case studies directly on your DevSync profile.',
                  textAlign: TextAlign.center,
                  style: AppStyles.body13Secondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Behance Username or Profile URL',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameCtrl,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText: 'e.g. designername or behance.net/designername',
                    hintStyle: AppStyles.body13Secondary(context),
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      size: 18,
                      color: c.primary,
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
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Design Tools (Optional)',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTools.map((tool) {
                    final selected = _selectedTools.contains(tool);
                    return FilterChip(
                      label: Text(
                        tool,
                        style: AppStyles.body12Medium(
                          context,
                          color: selected ? c.primary : c.textSecondary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: c.subtleBlueSurface,
                      checkmarkColor: c.primary,
                      backgroundColor: c.surface,
                      side: BorderSide(color: selected ? c.primary : c.border),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedTools.add(tool);
                          } else {
                            _selectedTools.remove(tool);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ProfileCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Case Studies (Optional)',
                  style: AppStyles.body13Bold(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Highlight your best Behance projects with links and cover previews.',
                  style: AppStyles.body12Secondary(context),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _shotTitleCtrl,
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText: 'Case study title (e.g. Fintech Mobile Redesign)',
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
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _shotUrlCtrl,
                  keyboardType: TextInputType.url,
                  style: AppStyles.body14Primary(context),
                  decoration: InputDecoration(
                    hintText: 'https://www.behance.net/gallery/...',
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
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _uploadingCover ? null : _pickShotCover,
                      icon: _uploadingCover
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_outlined, size: 16),
                      label: Text(
                        _pendingCoverUrl.isEmpty
                            ? 'Add Cover'
                            : 'Cover Added ✓',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.primary,
                        side: BorderSide(color: c.border),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _addShot,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Shot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: c.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_shots.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (var i = 0; i < _shots.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 18,
                            color: c.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _shots[i].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.body13Bold(context),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: c.error,
                            ),
                            onPressed: () => setState(() => _shots.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
