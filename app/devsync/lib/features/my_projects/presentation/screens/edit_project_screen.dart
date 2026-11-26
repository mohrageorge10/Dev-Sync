import 'package:devsync/core/shared/app_bar/custom_app_bar.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/project_model.dart';
import '../cubit/my_projects_cubit.dart';
import '../widgets/app_button.dart';
import '../widgets/edit_project_screen/edit_project_roles_card.dart';
import '../widgets/edit_project_screen/edit_project_tags_card.dart';
import '../widgets/section_card.dart';
import '../widgets/section_title.dart';

// Owner-only screen for editing project info, tech stack, and per-track seat counts.
class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({super.key, required this.project});

  final ProjectModel project;

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  static const List<String> _tracks = [
    'Mobile',
    'Frontend',
    'Backend',
    'Full-Stack',
    'UI/UX',
    'AI / ML',
    'DevOps',
    'QA / Testing',
    'Data',
    'Security',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final TextEditingController _tagInput = TextEditingController();

  late List<String> _tags;
  final Map<String, int> _trackCounts = {};
  String? _selectedTrack;

  int get _openSeats => _trackCounts.values.fold<int>(0, (s, n) => s + n);

  int get _computedSeats =>
      (widget.project.membersCount < 1 ? 1 : widget.project.membersCount) +
      _openSeats;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p.name);
    _descController = TextEditingController(text: p.description);
    _tags = List<String>.from(p.tags);
    _parseInitialRoles(p.openRoles);
  }

  void _parseInitialRoles(List<String> roles) {
    final pattern = RegExp(r'^(.+?)\s*[×x]\s*(\d+)$');
    for (final raw in roles) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final match = pattern.firstMatch(trimmed);
      if (match != null) {
        final name = match.group(1)!.trim();
        final count = int.tryParse(match.group(2)!) ?? 1;
        _trackCounts[name] = (_trackCounts[name] ?? 0) + count;
      } else {
        _trackCounts[trimmed] = (_trackCounts[trimmed] ?? 0) + 1;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _tagInput.text.trim();
    if (text.isEmpty || _tags.contains(text)) return;
    setState(() {
      _tags.add(text);
      _tagInput.clear();
    });
  }

  void _addSelectedTrack(String? track) {
    if (track == null || track.isEmpty) return;
    setState(() {
      _trackCounts[track] = (_trackCounts[track] ?? 0) + 1;
      _selectedTrack = null;
    });
  }

  void _changeCount(String track, int delta) {
    setState(() {
      final next = (_trackCounts[track] ?? 0) + delta;
      if (next <= 0) {
        _trackCounts.remove(track);
      } else if (next <= 10) {
        _trackCounts[track] = next;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final serializedRoles = [
      for (final entry in _trackCounts.entries)
        entry.value > 1 ? '${entry.key} ×${entry.value}' : entry.key,
    ];
    await context.read<MyProjectsCubit>().updateProjectDetails(
      widget.project.id,
      name: _nameController.text,
      description: _descController.text,
      totalSeats: _computedSeats,
      tags: _tags,
      openRoles: serializedRoles,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filled = widget.project.membersCount < 1
        ? 1
        : widget.project.membersCount;
    final availableTracks =
        _tracks.where((t) => !_trackCounts.containsKey(t)).toList();

    return Scaffold(
      backgroundColor: c.surface,
      appBar: CustomAppBar(
        title: 'Edit Project',
        showActions: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: c.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Basic Info'),
                  AppInputField(
                    controller: _nameController,
                    label: 'Project Title',
                    trailingLabel: 'Required',
                    hint: 'Enter project name',
                    inputFormatters: [LengthLimitingTextInputFormatter(80)],
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Title must be at least 3 characters'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppInputField(
                    controller: _descController,
                    label: 'Description',
                    trailingLabel: 'Required',
                    hint: 'Describe your project goals and scope...',
                    maxLines: 4,
                    inputFormatters: [LengthLimitingTextInputFormatter(300)],
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Description must be at least 10 characters'
                        : null,
                  ),
                ],
              ),
            ),
            EditProjectTagsCard(
              controller: _tagInput,
              tags: _tags,
              onAdd: _addTag,
              onRemoveAt: (i) => setState(() => _tags.removeAt(i)),
            ),
            EditProjectRolesCard(
              filledMembers: filled,
              openSeats: _openSeats,
              totalSeats: _computedSeats,
              availableTracks: availableTracks,
              selectedTrack: _selectedTrack,
              trackCounts: _trackCounts,
              onAddTrack: _addSelectedTrack,
              onChangeCount: _changeCount,
            ),
            const SizedBox(height: 4),
            AppButton(label: 'Save Changes', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
