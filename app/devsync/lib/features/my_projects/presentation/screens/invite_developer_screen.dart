import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/developer_model.dart';
import '../../data/models/project_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/invite_developer_screen/developer_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';

// Screen for inviting a developer to an owned project with a selected role and note.
class InviteDeveloperScreen extends StatefulWidget {
  const InviteDeveloperScreen({super.key, required this.developer});

  final DeveloperModel developer;

  @override
  State<InviteDeveloperScreen> createState() => _InviteDeveloperScreenState();
}

class _InviteDeveloperScreenState extends State<InviteDeveloperScreen> {
  final _messageController = TextEditingController();
  List<ProjectModel> _myProjects = [];
  ProjectModel? _selectedProject;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    final state = context.read<MyProjectsCubit>().state;
    if (state is MyProjectsLoaded) {
      _myProjects = state.ongoing
          .where((p) => p.isOwner && p.openRoles.isNotEmpty)
          .toList();
    }
    if (_myProjects.isNotEmpty) {
      _selectedProject = _myProjects.first;
      _selectedRole = _selectedProject!.openRoles.first;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _send() {
    if (_selectedProject == null || _selectedRole == null) {
      AppFeedback.show(
        context,
        message: 'Please select a project and a role.',
        type: AppFeedbackType.error,
      );
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      AppFeedback.show(
        context,
        message: 'Please write a short message.',
        type: AppFeedbackType.error,
      );
      return;
    }
    context.read<MyProjectsCubit>().sendInvitation(
      project: _selectedProject!,
      developer: widget.developer,
      role: _selectedRole!,
      message: _messageController.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Invite Developer',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DeveloperCard(developer: widget.developer),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdownField<ProjectModel>(
                  label: 'Select Project',
                  hint: 'Choose an active project',
                  value: _selectedProject,
                  items: _myProjects,
                  itemLabel: (p) => p.name,
                  onChanged: (project) => setState(() {
                    _selectedProject = project;
                    _selectedRole = project?.openRoles.firstOrNull;
                  }),
                ),
                const SizedBox(height: 16),
                const SectionTitle('Offered Role'),
                if (_selectedProject != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final role in _selectedProject!.openRoles)
                        ChoiceChip(
                          label: Text(role),
                          selected: _selectedRole == role,
                          selectedColor: c.subtleBlueSurface,
                          labelStyle: AppStyles.body12SemiBold(
                            context,
                            color: _selectedRole == role
                                ? c.primary
                                : c.textPrimary,
                          ),
                          side: BorderSide(
                            color: _selectedRole == role ? c.primary : c.border,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedRole = role),
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                AppInputField(
                  controller: _messageController,
                  label: 'Personal Message',
                  trailingLabel: 'Required',
                  hint: 'Tell them why you want them on your team...',
                  maxLines: 5,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AppButton(label: 'Send Invitation', onPressed: _send),
        ],
      ),
    );
  }
}
