import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/widgets/basic/profile_avatar_picker.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_field_decoration.dart';
import 'package:devsync/features/profile/presentation/widgets/profile_section_label.dart';
import 'package:flutter/material.dart';

// Basic info form section for the standalone Edit Profile screen.
class EditBasicSection extends StatelessWidget {
  const EditBasicSection({
    super.key,
    required this.profile,
    required this.nameController,
    required this.userController,
    required this.bioController,
  });

  final ProfileController profile;
  final TextEditingController nameController;
  final TextEditingController userController;
  final TextEditingController bioController;

  Widget? _usernameSuffix(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ProfileAvatarPicker(profile: profile),
        const ProfileSectionLabel('Display name', icon: Icons.person_outline),
        AppInputField(
          controller: nameController,
          hint: 'Your full name',
          prefixIcon: Icons.badge_outlined,
          onChanged: (v) => profile.setBasic(name: v),
        ),
        const ProfileSectionLabel('Username', icon: Icons.alternate_email),
        AppInputField(
          controller: userController,
          hint: 'username',
          prefixIcon: Icons.alternate_email,
          onChanged: (v) => profile.setBasic(user: v),
          suffixIcon: _usernameSuffix(context),
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
          icon: Icons.notes_rounded,
        ),
        TextField(
          controller: bioController,
          maxLength: 200,
          maxLines: 3,
          style: AppStyles.inputText(context),
          onChanged: (v) => profile.setBasic(bioText: v),
          decoration: profileFieldDecoration(
            context,
            counterText: '',
            hintText: 'Tell teammates what you build and enjoy working on…',
          ),
        ),
      ],
    );
  }
}
