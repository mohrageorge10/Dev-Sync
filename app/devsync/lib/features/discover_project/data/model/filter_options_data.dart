import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:flutter/material.dart';

// Filter options aligned with core enums.
class FilterOptionsData {
  FilterOptionsData._();

  static const List<String> skills = [
    'Flutter',
    'Dart',
    'React',
    'TypeScript',
    'Node.js',
    'Go',
    'Python',
    'PyTorch',
    'PostgreSQL',
    'Firebase',
    'Figma',
    'Docker',
  ];

  // Tracks from UserTrack enum.
  static final List<String> tracks = [
    for (final t in UserTrack.values) t.label,
  ];

  // Purposes from ProjectPurpose enum.
  static final List<String> purposes = [
    'All',
    for (final p in ProjectPurpose.values) p.label,
  ];

  // All 4 difficulty levels from ProjectDifficulty enum.
  static final List<String> difficulty = [
    for (final d in ProjectDifficulty.values) d.label,
  ];

  static const List<String> teamSizes = [
    'Solo (1)',
    'Small (2-4)',
    'Med (5-8)',
    'Large (9+)',
  ];

  // Section icons.
  static const IconData skillsIcon = Icons.code;
  static const IconData tracksIcon = Icons.groups_outlined;
  static const IconData purposeIcon = Icons.flag_outlined;
  static const IconData difficultyIcon = Icons.signal_cellular_alt;
  static const IconData teamIcon = Icons.group_outlined;
  static const IconData statusIcon = Icons.hourglass_empty;
}
