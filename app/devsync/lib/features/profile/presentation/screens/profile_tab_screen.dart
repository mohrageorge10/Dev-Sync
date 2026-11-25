import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/screens/developer_snapshot_screen.dart';
import 'package:flutter/material.dart';

// Profile tab embedded inside MainScreen, synced with Firestore on load.
class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key, this.onProfileUpdated});

  final VoidCallback? onProfileUpdated;

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.get<ProfileController>();
    _controller.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScope(
      controller: _controller,
      child: DeveloperSnapshotScreen(
        embedded: true,
        onProfileUpdated: widget.onProfileUpdated,
      ),
    );
  }
}
