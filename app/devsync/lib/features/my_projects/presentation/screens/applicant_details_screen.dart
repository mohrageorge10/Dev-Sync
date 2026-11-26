import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/discover_project/presentation/screens/public_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/applicant_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/applicant_details_screen/applicant_header_card.dart';
import '../widgets/applicant_details_screen/cover_note_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';
import '../widgets/skill_chip.dart';

// Screen showing full applicant details with profile preview and Accept/Decline actions.
class ApplicantDetailsScreen extends StatelessWidget {
  const ApplicantDetailsScreen({super.key, required this.applicant});

  final ApplicantModel applicant;

  Future<void> _openFullProfile(BuildContext context) async {
    final c = context.colors;
    final cubit = context.read<MyProjectsCubit>();
    final developer = await cubit.resolveApplicantProfile(applicant);
    if (!context.mounted) return;
    final decision = await Navigator.of(context).push<bool>(
      AppPageRoute(
        builder: (profileCtx) => PublicProfileScreen(
          developer: developer,
          customBottomBar: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Decline',
                  outlined: true,
                  color: c.error,
                  onPressed: () => Navigator.of(profileCtx).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  onPressed: () => Navigator.of(profileCtx).pop(true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (decision != null && context.mounted) {
      cubit.respondToApplicant(applicant.id, decision);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<MyProjectsCubit>();

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Applicant Details',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ApplicantHeaderCard(
            applicant: applicant,
            onViewProfile: () => _openFullProfile(context),
          ),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Requested Position'),
                Text(
                  applicant.position,
                  style: AppStyles.body13Primary(context),
                ),
                const SizedBox(height: 12),
                const SectionTitle('Skills'),
                SkillWrap(applicant.skills),
              ],
            ),
          ),
          CoverNoteCard(note: applicant.coverNote),
          const SizedBox(height: 8),
          AppButton(
            label: 'Accept Request',
            onPressed: () {
              cubit.respondToApplicant(applicant.id, true);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Decline Application',
            outlined: true,
            color: c.error,
            onPressed: () {
              cubit.respondToApplicant(applicant.id, false);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
