import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// Circular avatar selector with runtime camera/gallery permission checks.
class ProfileAvatarPicker extends StatelessWidget {
  const ProfileAvatarPicker({super.key, required this.profile});

  final ProfileController profile;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<bool> _ensurePermission(
    BuildContext context,
    ImageSource source,
  ) async {
    if (!_isMobile) return true;

    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
      if (status.isDenied &&
          defaultTargetPlatform == TargetPlatform.android) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted || status.isLimited) return true;

    if (!context.mounted) return false;
    final label = source == ImageSource.camera ? 'Camera' : 'Gallery';
    if (status.isPermanentlyDenied) {
      AppFeedback.show(
        context,
        message: '$label permission is permanently denied. Enable it in Settings.',
        type: AppFeedbackType.warning,
        actionLabel: 'Settings',
        onAction: openAppSettings,
      );
    } else {
      AppFeedback.show(
        context,
        message: '$label permission is required to choose a profile photo.',
        type: AppFeedbackType.warning,
      );
    }
    return false;
  }

  Future<void> _pickAvatar(BuildContext context, ImageSource source) async {
    final allowed = await _ensurePermission(context, source);
    if (!allowed || !context.mounted) return;

    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final error = await profile.uploadAvatar(
        bytes: bytes,
        fileName: file.name,
      );
      if (!context.mounted) return;
      if (error != null) {
        AppFeedback.show(context, message: error, type: AppFeedbackType.error);
      } else {
        AppFeedback.show(
          context,
          message: 'Profile photo updated.',
          type: AppFeedbackType.success,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppFeedback.show(
        context,
        message: "Couldn't open the picker: $e",
        type: AppFeedbackType.error,
      );
    }
  }

  void _showPickerSheet(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: c.backgroundPrimary,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              ListTile(
                leading: Icon(Icons.photo_camera_outlined, color: c.textPrimary),
                title: Text('Take a photo', style: AppStyles.body14Primary(ctx)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAvatar(context, ImageSource.camera);
                },
              ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: c.textPrimary),
              title: Text(
                'Choose from gallery',
                style: AppStyles.body14Primary(ctx),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(context, ImageSource.gallery);
              },
            ),
            if (profile.hasAvatar)
              ListTile(
                leading: Icon(Icons.delete_outline, color: c.error),
                title: Text(
                  'Remove photo',
                  style: AppStyles.body14Bold(ctx, color: c.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  profile.clearAvatar();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ImageProvider? imageProvider = profile.avatarBytes != null
        ? MemoryImage(profile.avatarBytes!)
        : (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
        ? NetworkImage(profile.photoUrl!)
        : null;

    return Center(
      child: GestureDetector(
        onTap: profile.isUploadingAvatar
            ? null
            : () => _showPickerSheet(context),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: c.subtleBlueSurface,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person_outline, size: 46, color: c.primary)
                  : null,
            ),
            if (profile.isUploadingAvatar)
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: c.primary,
                child: Icon(Icons.photo_camera, size: 16, color: c.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
