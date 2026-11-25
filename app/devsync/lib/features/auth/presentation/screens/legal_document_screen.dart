import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:flutter/material.dart';

// Legal document type displayed on LegalDocumentScreen.
enum LegalDocType { terms, privacy }

// Screen displaying DevSync Terms of Service or Privacy Policy.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocType type;

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalDocType.terms;
    final sections = isTerms ? _termsSections : _privacySections;

    return Scaffold(
      appBar: AuthAppBar(
        title: isTerms ? 'Terms of Service' : 'Privacy Policy',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTerms ? 'DevSync Terms of Service' : 'DevSync Privacy Policy',
                style: AppStyles.h2(context),
              ),
              const SizedBox(height: 6),
              Text(
                'Last updated: November 2026',
                style: AppStyles.body12Secondary(context),
              ),
              const SizedBox(height: 20),
              for (final s in sections) ...[
                _LegalSectionCard(title: s.title, body: s.body),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppStyles.title15Bold(context)),
          const SizedBox(height: 8),
          Text(body, style: AppStyles.body13Secondary(context)),
        ],
      ),
    );
  }
}

const _termsSections = [
  (
    title: '1. Acceptance of Terms',
    body:
        'By creating a DevSync account or browsing projects as a guest, you agree to follow these Terms of Service and our community guidelines.',
  ),
  (
    title: '2. Accounts & Eligibility',
    body:
        'You are responsible for keeping your login credentials secure and ensuring that your profile skills, track, and portfolio details remain accurate.',
  ),
  (
    title: '3. Project Collaboration',
    body:
        'Project owners and contributors agree to collaborate respectfully, honor agreed milestones, and respect open-source licenses and intellectual property rights.',
  ),
  (
    title: '4. Acceptable Use',
    body:
        'Spam, harassment, impersonation, or uploading malicious repositories and links is strictly prohibited and may result in account suspension.',
  ),
  (
    title: '5. Updates to Terms',
    body:
        'We may update these terms as DevSync evolves. Continued use of the platform after updates means you accept the revised terms.',
  ),
];

const _privacySections = [
  (
    title: '1. Information We Collect',
    body:
        'We collect your name, email address, public profile details (skills, track, bio, portfolio links), and project activity to power collaboration and matching.',
  ),
  (
    title: '2. How We Use Your Data',
    body:
        'Your data is used to authenticate your account, match you with open projects and developers, manage team invitations, and improve platform reliability.',
  ),
  (
    title: '3. Public vs. Private Information',
    body:
        'Your public profile (name, @handle, track, skills, and bio) is visible to other developers. Your email address and private account settings remain private.',
  ),
  (
    title: '4. Data Storage & Security',
    body:
        'Account data is stored securely using Firebase Authentication and Cloud Firestore with strict access rules protecting private records.',
  ),
  (
    title: '5. Your Controls',
    body:
        'You can update your profile, disconnect external accounts, or request deletion of your account and associated data at any time.',
  ),
];
