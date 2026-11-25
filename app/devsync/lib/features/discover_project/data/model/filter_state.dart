import 'package:equatable/equatable.dart';

// Selected filters state aligned with core schema.
class FilterState extends Equatable {
  const FilterState({
    this.skills = const {},
    this.tracks = const {},
    this.purpose = 'All',
    this.difficulty = const {},
    this.teamSize = const {},
    this.showOpen = true,
    this.skillsQuery = '',
  });

  final Set<String> skills;
  final Set<String> tracks;
  final String purpose;
  final Set<String> difficulty;
  final Set<String> teamSize;
  final bool showOpen;
  final String skillsQuery;

  // Number of active filters.
  int get activeCount =>
      skills.length +
      tracks.length +
      difficulty.length +
      teamSize.length +
      (purpose != 'All' ? 1 : 0);

  // Summary text for matching card.
  String get summary {
    final all = [...skills, ...tracks, ...difficulty];
    if (all.isEmpty) return 'No filters selected';
    return 'Matching ${all.take(3).join(', ')} criteria';
  }

  // Active filter chips list.
  List<String> get chips => [
        ...skills,
        ...tracks,
        if (purpose != 'All') purpose,
        ...difficulty,
        ...teamSize,
      ];

  // Remove a single filter chip value.
  FilterState without(String value) => copyWith(
        skills: {...skills}..remove(value),
        tracks: {...tracks}..remove(value),
        difficulty: {...difficulty}..remove(value),
        teamSize: {...teamSize}..remove(value),
        purpose: purpose == value ? 'All' : purpose,
      );

  FilterState copyWith({
    Set<String>? skills,
    Set<String>? tracks,
    String? purpose,
    Set<String>? difficulty,
    Set<String>? teamSize,
    bool? showOpen,
    String? skillsQuery,
  }) =>
      FilterState(
        skills: skills ?? this.skills,
        tracks: tracks ?? this.tracks,
        purpose: purpose ?? this.purpose,
        difficulty: difficulty ?? this.difficulty,
        teamSize: teamSize ?? this.teamSize,
        showOpen: showOpen ?? this.showOpen,
        skillsQuery: skillsQuery ?? this.skillsQuery,
      );

  @override
  List<Object?> get props => [
        skills,
        tracks,
        purpose,
        difficulty,
        teamSize,
        showOpen,
        skillsQuery,
      ];
}
