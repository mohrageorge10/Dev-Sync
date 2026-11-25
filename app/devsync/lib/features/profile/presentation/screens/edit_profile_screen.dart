import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/edit/edit_basic_section.dart';
import 'package:devsync/features/profile/presentation/widgets/edit/edit_skills_links_section.dart';
import 'package:devsync/features/profile/presentation/widgets/edit/edit_technical_section.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_buttons.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:flutter/material.dart';

// Single-page Edit Profile screen separate from the multi-step completion wizard.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _userController;
  late final TextEditingController _bioController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _linkedinController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final profile = ProfileScope.of(context);
    _nameController = TextEditingController(text: profile.displayName);
    _userController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _portfolioController = TextEditingController(text: profile.portfolio);
    _linkedinController = TextEditingController(text: profile.linkedin);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _bioController.dispose();
    _portfolioController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _save(ProfileController profile) async {
    if (profile.displayName.trim().isEmpty) {
      AppFeedback.show(
        context,
        message: 'Display name cannot be empty.',
        type: AppFeedbackType.warning,
      );
      return;
    }
    if (profile.username.trim().length < 3) {
      AppFeedback.show(
        context,
        message: 'Username must be at least 3 characters.',
        type: AppFeedbackType.warning,
      );
      return;
    }
    final available = await profile.verifyUsernameNow();
    if (!mounted) return;
    if (!available) {
      AppFeedback.show(
        context,
        message: 'This username is already taken.',
        type: AppFeedbackType.warning,
      );
      return;
    }

    await profile.saveProfile();
    if (!mounted) return;
    AppFeedback.show(
      context,
      message: 'Profile updated successfully.',
      type: AppFeedbackType.success,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'Edit Profile',
      footer: ProfilePrimaryButton(
        profile.isSaving ? 'Saving...' : 'Save Changes',
        icon: Icons.check_rounded,
        onPressed: profile.isSaving ? null : () => _save(profile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditBasicSection(
            profile: profile,
            nameController: _nameController,
            userController: _userController,
            bioController: _bioController,
          ),
          EditTechnicalSection(profile: profile),
          EditSkillsLinksSection(
            profile: profile,
            portfolioController: _portfolioController,
            linkedinController: _linkedinController,
          ),
        ],
      ),
    );
  }
}
