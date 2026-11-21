import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/profile_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  double progressValue = 0.2;

  File? _avatarImage;

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            CustomProgressBar(progressValue: progressValue),
            const SizedBox(height: 24),
            const Text(
              "Let's set up your profile",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0XFF0F1C31),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Help teammates understand who you are and what \n you build.',
              style: TextStyle(fontSize: 14, color: Color(0XFF434654)),
            ),

            const SizedBox(height: 28),
            // Avatar picker placeholder — displays a tappable circle with a camera icon
            Center(
              child: GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFFEEF3FF),
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : null,
                      child: _avatarImage == null
                          ? const Icon(Icons.person, size: 48, color: Color(0xFF315BDB))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF315BDB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your DevSync ID',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Color(0XFF434654),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0XFFDFE8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Auto-generated',
                    style: TextStyle(
                      color: Color(0XFF315BDB),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0XFFF1F3FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    '# ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF747686),
                    ),
                  ),
                  const Text(
                    'DS-89241',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF0F1C31),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'DS-89241'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Color(0XFF315BDB),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Unique technical fingerprint for peer requests.',
              style: TextStyle(fontSize: 12, color: Color(0XFF434654)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Display name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0XFF0F1C31),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: Color(0XFF747686),
                ),
                filled: true,
                fillColor: const Color(0XFFF1F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              'Username',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0XFF0F1C31),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    '@',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF747686),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                suffixIcon: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0XFF315BDB),
                ),
                filled: true,
                fillColor: const Color(0XFFF1F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Available on devsync.net/${_usernameController.text}',
              style: const TextStyle(fontSize: 14, color: Color(0XFF315BDB)),
            ),

            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Short bio',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xff0F1C31),
                  ),
                ),
                Text(
                  '${_bioController.text.length} / 200',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0XFF434654),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
              onChanged: (val) {
                setState(() {});
              },
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: const Color(0XFFF1F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outlined,
                  size: 14,
                  color: Color(0XFF315BDB),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'A great bio mentions your preferred stack and project \n goals.',
                    style: TextStyle(fontSize: 12, color: Color(0XFF434654)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // TODO: replace with AccountTypeScreen when available
                      builder: (context) => const Scaffold(
                        body: Center(child: Text('Account Type')),
                      ),
                    ),
                  );
                },
                buttonText: 'Continue',
                trailingIcon: Icons.arrow_forward,
                isDisabled: false,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 12, color: Color(0XFF434654)),
                SizedBox(width: 4),
                Text(
                  'You can modify your profile details at any time',
                  style: TextStyle(fontSize: 11, color: Color(0XFF434654)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// الـ Widget المنفصلة
class CustomProgressBar extends StatelessWidget {
  final double progressValue;

  const CustomProgressBar({
    super.key,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${(progressValue * 100).toInt()}% completed',
              style: const TextStyle(
                color: Color(0XFF434654),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 5,
            backgroundColor: const Color(0XFFDFE8FF),
            color: const Color(0XFF315BDB),
          ),
        ),
      ],
    );
  }
}