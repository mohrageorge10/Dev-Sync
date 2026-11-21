import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/discover_project/data/model/filter_options_data.dart';
import 'package:devsync/features/discover_project/data/model/filter_matching.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:flutter/material.dart';

// Discoverable project model mapped from Firestore.
class ProjectModel {
  const ProjectModel({
    required this.id,
    this.ownerId = '',
    required this.title,
    required this.icon,
    required this.type,
    required this.matchPercent,
    required this.createdAgo,
    required this.ageHours,
    required this.status,
    required this.description,
    required this.matchReason,
    required this.tags,
    required this.tracks,
    this.openTracks = const [],
    required this.difficulty,
    required this.members,
    required this.maxMembers,
    required this.needs,
  });

  // Parse from Firestore project document.
  factory ProjectModel.fromFirestore(Map<String, dynamic> map) {
    final id = (map['id'] ?? '').toString();
    final rawPurpose = (map[FirebaseConstants.fieldPurpose] ?? 'real').toString();
    final purpose = rawPurpose == ProjectPurpose.learning.name
        ? ProjectPurpose.learning
        : ProjectPurpose.real;

    final rawDiff =
        (map[FirebaseConstants.fieldDifficulty] ?? 'intermediate').toString();
    final diff = ProjectDifficulty.values.firstWhere(
      (d) => d.name == rawDiff.toLowerCase(),
      orElse: () => ProjectDifficulty.intermediate,
    );

    final rawStack = map[FirebaseConstants.fieldTechStack];
    final tags = <String>[
      if (rawStack is Iterable)
        for (final s in rawStack) s.toString(),
    ];

    final rawTrackKeys = map[FirebaseConstants.fieldTrackKeys];
    final trackLabels = <String>[
      if (rawTrackKeys is Iterable)
        for (final k in rawTrackKeys) UserTrackX.fromName(k.toString()).label,
    ];

    final rawOpenKeys = map[FirebaseConstants.fieldOpenTrackKeys];
    final openLabels = <String>[
      if (rawOpenKeys is Iterable)
        for (final k in rawOpenKeys) UserTrackX.fromName(k.toString()).label,
    ];

    final teamSize = (map[FirebaseConstants.fieldTeamSize] as num?)?.toInt() ?? 4;
    final filled =
        (map[FirebaseConstants.fieldFilledCount] as num?)?.toInt() ?? 1;

    return ProjectModel(
      id: id,
      ownerId: (map[FirebaseConstants.fieldOwnerId] ?? '').toString(),
      title: (map[FirebaseConstants.fieldTitle] ?? 'Untitled Project').toString(),
      icon: purpose.icon,
      type: purpose.label,
      matchPercent: 88,
      createdAgo: 'Recently published',
      ageHours: 2,
      status: openLabels.isEmpty
          ? 'Team Full'
          : '${openLabels.length} tracks open',
      description:
          (map[FirebaseConstants.fieldDescription] ?? '').toString(),
      matchReason: tags.isNotEmpty
          ? 'Matches your ${tags.take(2).join(' & ')} stack'
          : 'Great match for your engineering track',
      tags: tags,
      tracks: trackLabels.isEmpty ? const ['Mobile'] : trackLabels,
      openTracks: openLabels,
      difficulty: diff.label,
      members: filled,
      maxMembers: teamSize,
      needs: openLabels.isEmpty ? 'All roles filled' : openLabels.join(', '),
    );
  }

  final String id;
  final String ownerId;
  final String title;
  final IconData icon;
  final String type;
  final int matchPercent;
  final String createdAgo;
  final int ageHours;
  final String status;
  final String description;
  final String matchReason;
  final List<String> tags;
  final List<String> tracks;
  final List<String> openTracks;
  final String difficulty;
  final int members;
  final int maxMembers;
  final String needs;

  bool get isOpen => members < maxMembers;

  // Effective open track labels (falls back to parsed `needs` for local data).
  List<String> get effectiveOpenTracks {
    if (openTracks.isNotEmpty) return openTracks;
    if (!isOpen) return const [];
    return needs
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.toLowerCase() != 'all roles filled')
        .toList();
  }

  // Returns true if project is open and matches user's track or at least one skill.
  bool isEligibleFor({
    String? userTrack,
    List<String> userSkills = const [],
  }) {
    if (!isOpen) return false;
    final cleanTrack = userTrack?.trim().toLowerCase() ?? '';
    final cleanSkills = userSkills
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toSet();

    // If user hasn't set track or skills yet, allow open projects.
    if (cleanTrack.isEmpty && cleanSkills.isEmpty) return true;

    final trackMatches = cleanTrack.isNotEmpty &&
        effectiveOpenTracks.any((t) => t.toLowerCase() == cleanTrack);

    final skillMatches = cleanSkills.isNotEmpty &&
        tags.any((tag) => cleanSkills.contains(tag.trim().toLowerCase()));

    return trackMatches || skillMatches;
  }

  bool get isRealWorld => type.toLowerCase() != 'learning';

  String get matchPercentageText => '$matchPercent% Match';

  String get membersFilledText => '$members/$maxMembers members filled';

  // Team size category label.
  String get teamSizeLabel {
    final sizes = FilterOptionsData.teamSizes;
    if (maxMembers <= 1) return sizes[0];
    if (maxMembers <= 4) return sizes[1];
    if (maxMembers <= 8) return sizes[2];
    return sizes[3];
  }

  // Match against active filters.
  bool matches(FilterState f) =>
      matchesAny(f.skills, tags) &&
      (matchesAny(f.tracks, tracks) || textContainsAny(f.tracks, [needs])) &&
      (f.purpose == 'All' || type == f.purpose) &&
      matchesAny(f.difficulty, [difficulty]) &&
      (f.teamSize.isEmpty || f.teamSize.contains(teamSizeLabel)) &&
      (isOpen == f.showOpen);

  // Match against search query.
  bool matchesQuery(String query) =>
      containsQuery(query, [title, description, needs, ...tags, ...tracks]);

  // Match against a single tech stack chip (used in guest mode).
  bool matchesSkillChip(String selectedSkill) {
    if (selectedSkill == 'All Stacks') return true;
    final wanted = selectedSkill.toLowerCase().split(' ').first;
    return tags.any((t) => t.toLowerCase().contains(wanted)) ||
        tracks.any((t) => t.toLowerCase().contains(wanted));
  }
}
