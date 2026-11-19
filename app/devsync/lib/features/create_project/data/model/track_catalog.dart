import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Track definition and suggested skills.
class TrackDefinition extends Equatable {
  const TrackDefinition({required this.track, required this.skills});

  final UserTrack track;
  final List<String> skills;

  String get id => track.name;
  String get name => track.label;
  IconData get icon => track.icon;

  @override
  List<Object?> get props => [track, skills];
}

// Available tracks catalog.
class TrackCatalog {
  const TrackCatalog._();

  static const all = <TrackDefinition>[
    TrackDefinition(
      track: UserTrack.mobile,
      skills: ['Dart', 'Flutter', 'Firebase', 'State Management', 'Testing'],
    ),
    TrackDefinition(
      track: UserTrack.web,
      skills: ['React', 'TypeScript', 'Next.js', 'Tailwind', 'Node.js'],
    ),
    TrackDefinition(
      track: UserTrack.backend,
      skills: ['PostgreSQL', 'Go', 'Node.js', 'Redis', 'GraphQL'],
    ),
    TrackDefinition(
      track: UserTrack.data,
      skills: ['Python', 'SQL', 'Machine Learning', 'ETL', 'Visualization'],
    ),
    TrackDefinition(
      track: UserTrack.ai,
      skills: ['PyTorch', 'LangChain', 'LLMs', 'HuggingFace', 'Python', 'Vector DBs'],
    ),
    TrackDefinition(
      track: UserTrack.uiux,
      skills: ['Figma', 'Prototyping', 'Design Systems', 'User Research', 'Motion'],
    ),
    TrackDefinition(
      track: UserTrack.qa,
      skills: ['Cypress', 'Selenium', 'Jest', 'Postman', 'Appium'],
    ),
    TrackDefinition(
      track: UserTrack.devops,
      skills: ['Docker', 'Kubernetes', 'CI/CD', 'Terraform', 'AWS'],
    ),
  ];

  static TrackDefinition byTrack(UserTrack track) =>
      all.firstWhere((t) => t.track == track, orElse: () => all.first);

  static TrackDefinition byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}
