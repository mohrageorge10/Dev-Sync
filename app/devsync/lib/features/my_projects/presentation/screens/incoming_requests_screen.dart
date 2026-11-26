import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/incoming_requests_screen/applicant_card.dart';
import 'applicant_details_screen.dart';

// Screen listing pending join requests for a project.
class IncomingRequestsScreen extends StatelessWidget {
  const IncomingRequestsScreen({super.key, this.projectId});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Incoming Requests',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<MyProjectsCubit, MyProjectsState>(
        builder: (context, state) {
          if (state is! MyProjectsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final applicants = projectId == null
              ? state.pendingApplicants
              : state.pendingApplicantsFor(projectId!);

          if (applicants.isEmpty) {
            return Center(
              child: Text(
                'No pending requests',
                style: AppStyles.body14Secondary(context),
              ),
            );
          }

          final cubit = context.read<MyProjectsCubit>();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: applicants
                .map(
                  (a) => ApplicantCard(
                    applicant: a,
                    onReview: () => Navigator.of(context).push(
                      AppPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: ApplicantDetailsScreen(applicant: a),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
