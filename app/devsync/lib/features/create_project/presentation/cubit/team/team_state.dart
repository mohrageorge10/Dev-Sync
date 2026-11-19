import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:equatable/equatable.dart';

// Immutable snapshot of the team + derived numbers for the UI.
class TeamState extends Equatable {
  const TeamState({this.tracks = const []});

  final List<TeamTrack> tracks;

  // Total headcount of all tracks.
  int get totalPeople => tracks.fold(0, (s, t) => s + t.people);

  // Number of invitations already sent.
  int get pendingInvites => tracks.fold(0, (s, t) => s + t.invites.length);

  // Number of different skills across the tracks.
  int get distinctSkills => tracks.expand((t) => t.skills).toSet().length;

  // Lookups.
  bool hasTrack(String id) => tracks.any((t) => t.definition.id == id);

  TeamTrack? byId(String id) =>
      tracks.where((t) => t.definition.id == id).firstOrNull;

  // Track that still needs the most people.
  TeamTrack? get mostOpenTrack {
    final open = tracks.where((t) => t.openSpots > 0).toList()
      ..sort((a, b) => b.openSpots.compareTo(a.openSpots));
    return open.firstOrNull;
  }

  // Fields used for equality.
  @override
  List<Object?> get props => [tracks];
}
