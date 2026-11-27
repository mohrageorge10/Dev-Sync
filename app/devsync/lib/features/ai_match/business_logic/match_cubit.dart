import 'dart:async';

import 'package:devsync/features/ai_match/business_logic/match_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Loads and streams the user's match history (best score first).
class MatchCubit extends Cubit<MatchState> {
  MatchCubit(this._repo, {Stream<String?>? userIdChanges})
      : super(const MatchInitial()) {
    // Login / logout -> reload matches and re-bind real-time stream.
    _sub = userIdChanges?.distinct().skip(1).listen((_) => load(silent: true));
  }

  final MatchRepo _repo;
  StreamSubscription<String?>? _sub;
  StreamSubscription<List<MatchModel>>? _matchesSub;
  bool _busy = false;

  /// [silent] = pull to refresh: keep the list on screen while loading
  /// and keep the old list if the refresh fails.
  Future<void> load({bool silent = false}) async {
    if (_busy) return;
    _busy = true;
    final keepList = silent && state is MatchLoaded;
    if (!keepList) emit(const MatchLoading());
    try {
      final matches = await _repo.getMatches();
      if (isClosed) return;
      // Best score first, whatever order the repo returns.
      final sorted = [...matches]..sort((a, b) => b.score.compareTo(a.score));
      emit(MatchLoaded(sorted));
      _startMatchesStream();
    } catch (_) {
      if (isClosed || keepList) return;
      emit(const MatchError(AiMatchStrings.genericError));
    } finally {
      _busy = false;
    }
  }

  void _startMatchesStream() {
    _matchesSub?.cancel();
    _matchesSub = _repo.watchMatches().listen((live) {
      if (isClosed || live.isEmpty) return;
      final sorted = [...live]..sort((a, b) => b.score.compareTo(a.score));
      emit(MatchLoaded(sorted));
    }, onError: (_) {});
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _matchesSub?.cancel();
    return super.close();
  }
}
