import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/basic/profile_avatar_picker.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_decoration.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_scaffold.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_footer.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_step_progress.dart';
import 'package:flutter/material.dart';

// Step 1 of profile setup: avatar, display name, unique username, and bio.
class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _userController;
  late final TextEditingController _bioController;
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget? _usernameSuffix(BuildContext context, ProfileController profile) {
    final c = context.colors;
    if (profile.isCheckingUsername) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.primary),
        ),
      );
    }
    if (profile.isUsernameAvailable == true) {
      return Icon(Icons.check_circle, size: 18, color: c.success);
    }
    if (profile.isUsernameAvailable == false) {
      return Icon(Icons.cancel_rounded, size: 18, color: c.error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final profile = ProfileScope.of(context);

    return ProfileScaffold(
      title: 'Basic Info',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileStepFooter(
            showBack: false,
            blockedReason: profile.basicBlockedReason,
            onContinue: () async {
              final available = await profile.verifyUsernameNow();
              if (!context.mounted) return;
              if (!available) {
                AppFeedback.show(
                  context,
                  message: 'This username is already taken.',
                  type: AppFeedbackType.warning,
                );
                return;
              }
              await profile.saveProfile();
              if (!context.mounted) return;
              Navigator.pushNamed(context, AppRoutes.profileTechnical);
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 12, color: c.textSecondary),
              const SizedBox(width: 4),
              Text(
                'You can modify your profile details at any time',
                style: AppStyles.body11Secondary(context),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStepProgress(20),
          Text("Let's set up your profile", style: AppStyles.h28(context)),
          const SizedBox(height: 4),
          Text(
            'Help teammates understand who you are and what you build.',
            style: AppStyles.body14Secondary(context),
          ),
          const SizedBox(height: 18),
          ProfileAvatarPicker(profile: profile),
          const ProfileSectionLabel('Display name'),
          AppInputField(
            controller: _nameController,
            hint: 'Alex Morgan',
            prefixIcon: Icons.badge_outlined,
            onChanged: (v) => profile.setBasic(name: v),
          ),
          const ProfileSectionLabel('Username'),
          AppInputField(
            controller: _userController,
            onChanged: (v) => profile.setBasic(user: v),
            prefixIcon: Icons.alternate_email,
            hint: 'alexmorgan',
            suffixIcon: _usernameSuffix(context, profile),
          ),
          if (profile.isUsernameAvailable == false)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'This username is already taken. Try another one.',
                style: AppStyles.body12Error(context),
              ),
            )
          else if (profile.isUsernameAvailable == true &&
              profile.username.trim().length >= 3)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '@${profile.username.trim()} is available',
                style: AppStyles.body11Medium(context, color: c.success),
              ),
            ),
          ProfileSectionLabel(
            'Short bio',
            trailing: '${profile.bio.length} / 200',
          ),
          TextField(
            controller: _bioController,
            maxLength: 200,
            maxLines: 3,
            style: AppStyles.inputText(context),
            onChanged: (v) => profile.setBasic(bioText: v),
            decoration: profileFieldDecoration(
              context,
              counterText: '',
              hintText:
                  'Full-stack developer fascinated by offline-first apps…',
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 14, color: c.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'A great bio mentions your preferred stack and project goals.',
                  style: AppStyles.body11Secondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
