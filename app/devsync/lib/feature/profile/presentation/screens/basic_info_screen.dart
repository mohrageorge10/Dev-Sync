import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devsync/core/routing/profile_routes.dart';
import '../widgets/profile_widgets.dart';
import '../cubit/profile_controller.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});
  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late final TextEditingController _name, _user, _bio;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final c = ProfileScope.of(context);
    _name = TextEditingController(text: c.displayName);
    _user = TextEditingController(text: c.username);
    _bio = TextEditingController(text: c.bio);
  }

  @override
  void dispose() {
    _name.dispose();
    _user.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source, ProfileController c) async {
    try {
      final x = await ImagePicker().pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (x == null) return; // user cancelled
      c.setAvatar(await x.readAsBytes());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Couldn\'t open the picker: $e')));
    }
  }

  void _showPickerSheet(ProfileController c) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () { Navigator.pop(ctx); _pick(ImageSource.camera, c); },
            ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () { Navigator.pop(ctx); _pick(ImageSource.gallery, c); },
          ),
          if (c.avatarBytes != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: ProfileColors.error),
              title: const Text('Remove photo', style: TextStyle(color: ProfileColors.error)),
              onTap: () { Navigator.pop(ctx); c.setAvatar(null); },
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ProfileScope.of(context);
    final userOk = c.username.trim().length >= 3;
    return AppScaffold(
      title: '',
      showBack: false,
      footer: Column(mainAxisSize: MainAxisSize.min, children: [
        StepFooter(showBack: false, blockedReason: c.basicBlockedReason, onContinue: () => Navigator.pushNamed(context, ProfileRoutes.technical)),
        const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.lock_outline, size: 12, color: ProfileColors.textSecondary)),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StepProgress(20),
        const Text('Let\'s set up your profile', style: ProfileStyles.title),
        const SizedBox(height: 4),
        const Text('Help teammates understand who you are and what you build.', style: ProfileStyles.body),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: () => _showPickerSheet(c),
            child: Stack(children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: ProfileColors.subtleBlueSurface,
                backgroundImage: c.avatarBytes == null ? null : MemoryImage(c.avatarBytes!),
                child: c.avatarBytes == null ? const Icon(Icons.person_outline, size: 46, color: ProfileColors.primary) : null,
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(radius: 16, backgroundColor: ProfileColors.primary, child: Icon(Icons.photo_camera, size: 16, color: Colors.white)),
              ),
            ]),
          ),
        ),
        const SectionLabel('Your DevSync ID'),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: c.devSyncId),
          decoration: fieldDeco(prefixIcon: Icon(Icons.tag, size: 18), suffixIcon: IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: c.devSyncId));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('DevSync ID copied'), behavior: SnackBarBehavior.floating));
              },
            )),
        ),
        const Text('Unique technical fingerprint for peer requests.', style: ProfileStyles.caption),
        const SectionLabel('Display name'),
        AppInputField(controller: _name, hint: 'Alex Morgan', prefixIcon: Icons.badge_outlined, onChanged: (v) => c.setBasic(name: v)),
        const SectionLabel('Username'),
        AppInputField(
          controller: _user,
          onChanged: (v) => c.setBasic(user: v),
          prefixIcon: Icons.alternate_email,
          hint: 'alexmorgan',
          suffixIcon: userOk ? const Icon(Icons.check_circle, size: 18, color: ProfileColors.primary) : null,
        ),
        SectionLabel('Short bio', trailing: '${c.bio.length} / 200'),
        TextField(
          controller: _bio,
          maxLength: 200,
          maxLines: 3,
          onChanged: (v) => c.setBasic(bioText: v),
          decoration: fieldDeco(counterText: '', hintText: 'Full-stack developer fascinated by offline-first apps…'),
        ),
        const Row(children: [
          Icon(Icons.lightbulb_outline, size: 14, color: ProfileColors.textSecondary),
          SizedBox(width: 6),
          Expanded(child: Text('A great bio mentions your preferred stack and project goals.', style: ProfileStyles.caption)),
        ]),
      ]),
    );
  }
}
