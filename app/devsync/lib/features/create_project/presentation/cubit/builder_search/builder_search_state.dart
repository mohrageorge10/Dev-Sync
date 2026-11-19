import 'package:devsync/features/create_project/data/model/scored_builder.dart';
import 'package:equatable/equatable.dart';

// Builder search sheet state.
class BuilderSearchState extends Equatable {
  const BuilderSearchState({
    this.query = '',
    this.results = const [],
    this.loading = false,
    this.selectedIds = const {},
    this.joinTrackId,
    this.lockedTrackId,
  });

  final String query;
  final List<ScoredBuilder> results;
  final bool loading;
  final Set<String> selectedIds;
  final String? joinTrackId;
  final String? lockedTrackId;

  String? get selectedId => selectedIds.firstOrNull;

  // Filter results by active track.
  List<ScoredBuilder> get visibleResults {
    final activeTrack = lockedTrackId ?? joinTrackId;
    if (activeTrack == null) return results;
    return results.where((r) => r.builder.trackId == activeTrack).toList();
  }

  List<ScoredBuilder> get selectedBuilders =>
      results.where((r) => selectedIds.contains(r.builder.id)).toList();

  BuilderSearchState copyWith({
    String? query,
    List<ScoredBuilder>? results,
    bool? loading,
    Set<String>? selectedIds,
    String? joinTrackId,
    String? lockedTrackId,
    bool clearSelection = false,
    bool clearTrackFilter = false,
  }) =>
      BuilderSearchState(
        query: query ?? this.query,
        results: results ?? this.results,
        loading: loading ?? this.loading,
        selectedIds:
            clearSelection ? const {} : (selectedIds ?? this.selectedIds),
        joinTrackId:
            clearTrackFilter ? lockedTrackId : (joinTrackId ?? this.joinTrackId),
        lockedTrackId: lockedTrackId ?? this.lockedTrackId,
      );

  @override
  List<Object?> get props =>
      [query, results, loading, selectedIds, joinTrackId, lockedTrackId];
}
