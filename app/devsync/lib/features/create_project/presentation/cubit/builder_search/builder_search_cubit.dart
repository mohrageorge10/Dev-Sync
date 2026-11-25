import 'dart:async';

import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/scored_builder.dart';
import 'package:devsync/features/create_project/data/model/slot_match.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';
import 'package:devsync/features/create_project/presentation/cubit/builder_search/builder_search_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Developer search, track filter, and multi-select cubit.
class BuilderSearchCubit extends Cubit<BuilderSearchState> {
  BuilderSearchCubit({
    required BuildersRepository repository,
    required TeamCubit teamCubit,
  })  : _repository = repository,
        _teamCubit = teamCubit,
        super(const BuilderSearchState());

  final BuildersRepository _repository;
  final TeamCubit _teamCubit;
  Timer? _debounce;
  String? _lockedTrackId;
  bool _explicitTrackChip = false;

  // Initial load.
  void start(String query, {String? trackId}) {
    _lockedTrackId = trackId;
    _explicitTrackChip = trackId != null;
    emit(
      state.copyWith(
        query: query,
        loading: true,
        lockedTrackId: trackId,
        joinTrackId: trackId,
        clearSelection: true,
      ),
    );
    _search(query);
  }

  // Debounced search on typing.
  void onQueryChanged(String q) {
    emit(state.copyWith(query: q, loading: true));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(q));
  }

  // Search and score builders against open tracks.
  Future<void> _search(String q) async {
    final found = await _repository.search(q);
    if (isClosed || state.query != q) return;

    final team = _teamCubit.state;
    final openSlots = _lockedTrackId == null
        ? team.tracks.where((t) => t.openSpots > 0).toList()
        : team.tracks
            .where((t) => t.definition.id == _lockedTrackId && t.openSpots > 0)
            .toList();
    final invited =
        team.tracks.expand((t) => t.invites.map((i) => i.builder.id)).toSet();

    final scored = <ScoredBuilder>[];
    for (final b in found) {
      if (invited.contains(b.id)) continue;
      final slot = _slotForTrack(b, openSlots);
      if (slot != null) scored.add(ScoredBuilder(b, slot));
    }

    scored.sort((a, b) => b.percent.compareTo(a.percent));
    emit(state.copyWith(results: scored, loading: false));
  }

  // Match builder strictly to their own track slot.
  SlotMatch? _slotForTrack(DevBuilder b, List<TeamTrack> openTracks) {
    for (final t in openTracks) {
      if (t.definition.id == b.trackId && t.openSpots > 0) {
        return SlotMatch(t, b.matchPercent(t));
      }
    }
    return null;
  }

  // Toggle selection bounded by open spots.
  String? toggleSelect(ScoredBuilder s) {
    final id = s.builder.id;
    final selected = {...state.selectedIds};

    if (selected.contains(id)) {
      selected.remove(id);
      emit(
        state.copyWith(
          selectedIds: selected,
          clearTrackFilter:
              selected.isEmpty && _lockedTrackId == null && !_explicitTrackChip,
        ),
      );
      return null;
    }

    final trackId = _lockedTrackId ?? state.joinTrackId ?? s.builder.trackId;
    final track = _teamCubit.state.byId(trackId);
    final maxSpots = track?.openSpots ?? 1;

    if (selected.length >= maxSpots) {
      return 'You can select at most $maxSpots developer${maxSpots > 1 ? 's' : ''} for ${track?.definition.name ?? 'this track'}.';
    }

    selected.add(id);
    emit(state.copyWith(selectedIds: selected, joinTrackId: trackId));
    return null;
  }

  // Filter by track chip.
  void setJoinTrack(String? trackId) {
    if (_lockedTrackId != null) return;
    if (trackId == null) {
      _explicitTrackChip = false;
      emit(state.copyWith(clearTrackFilter: true, clearSelection: true));
      return;
    }

    _explicitTrackChip = true;
    final maxSpots = _teamCubit.state.byId(trackId)?.openSpots ?? 1;
    final kept = state.selectedBuilders
        .where((r) => r.builder.trackId == trackId)
        .take(maxSpots)
        .map((r) => r.builder.id)
        .toSet();

    emit(state.copyWith(joinTrackId: trackId, selectedIds: kept));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
