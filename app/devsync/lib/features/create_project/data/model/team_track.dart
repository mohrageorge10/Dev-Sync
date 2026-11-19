import 'dart:math';

import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:equatable/equatable.dart';

// Pending developer invitation.
class Invite extends Equatable {
  const Invite(this.builder, {this.message = ''});

  final DevBuilder builder;
  final String message;

  @override
  List<Object?> get props => [builder, message];
}

// Track slot inside the project team.
class TeamTrack extends Equatable {
  const TeamTrack({
    required this.definition,
    this.people = 1,
    this.skills = const {},
    this.invites = const [],
  });

  final TrackDefinition definition;
  final int people;
  final Set<String> skills;
  final List<Invite> invites;

  // Remaining uninvited spots.
  int get openSpots => max(0, people - invites.length);

  TeamTrack copyWith({
    int? people,
    Set<String>? skills,
    List<Invite>? invites,
  }) =>
      TeamTrack(
        definition: definition,
        people: people ?? this.people,
        skills: skills ?? this.skills,
        invites: invites ?? this.invites,
      );

  @override
  List<Object?> get props => [definition, people, skills, invites];
}
