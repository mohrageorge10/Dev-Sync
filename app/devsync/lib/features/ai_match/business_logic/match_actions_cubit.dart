import 'dart:async';

import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Save (bookmark) and "Request to Join" of one recommended project.
class MatchActionsCubit extends Cubit<MatchActionsState> {
  MatchActionsCubit(this._repo, {Stream<String?>? userIdChanges})
      : super(const MatchActionsState()) {
    // Login / logout -> read the saved flag and request status again.
    _sub = userIdChanges?.distinct().skip(1).listen((_) {
      final id = _projectId;
      if (id != null) load(id);
    });
  }

  final MatchRepo _repo;
  StreamSubscription<String?>? _sub;
  String? _projectId;

  /// Loads the saved flag and the join request status of the project.
  Future<void> load(String projectId) async {
    _projectId = projectId;
    try {
      final saved = await _repo.isSaved(projectId);
      final request = await _repo.getJoinRequestStatus(projectId);
      if (!isClosed) {
        emit(state.copyWith(
          saved: saved,
          request: request,
          clearRequest: request == null,
        ));
      }
    } catch (_) {
      // Keep the default state: the buttons still work.
    }
  }

  Future<void> toggleSaved(MatchModel match) async {
    if (state.savingBookmark) return;
    final target = !state.saved;
    emit(state.copyWith(savingBookmark: true, saved: target)); // optimistic
    try {
      await _repo.setSaved(match, target);
      if (isClosed) return;
      emit(state.copyWith(
        savingBookmark: false,
        event: MatchActionEvent(
          target ? MatchActionEventKind.saved : MatchActionEventKind.unsaved,
          target ? AiMatchStrings.savedMsg : AiMatchStrings.unsavedMsg,
        ),
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        savingBookmark: false,
        saved: !target, // undo
        event: _eventFor(e),
      ));
    }
  }

  Future<void> requestToJoin(MatchModel match) async {
    // No double send, and no second request for the same project.
    if (state.sendingRequest || state.request != null) return;
    emit(state.copyWith(sendingRequest: true));
    try {
      await _repo.requestToJoin(match);
      if (isClosed) return;
      emit(state.copyWith(
        sendingRequest: false,
        request: RequestStatus.pending,
        event: MatchActionEvent(
          MatchActionEventKind.requestSent,
          AiMatchStrings.requestSentMsg,
        ),
      ));
    } catch (e) {
      if (isClosed) return;
      final already = e is MatchActionException &&
          e.error == MatchActionError.alreadyRequested;
      emit(state.copyWith(
        sendingRequest: false,
        request: already ? RequestStatus.pending : null,
        event: _eventFor(e),
      ));
    }
  }

  MatchActionEvent _eventFor(Object e) {
    if (e is MatchActionException) {
      return switch (e.error) {
        MatchActionError.notSignedIn =>
          MatchActionEvent(MatchActionEventKind.needsLogin),
        MatchActionError.projectNotFound => MatchActionEvent(
            MatchActionEventKind.error, AiMatchStrings.errProjectNotFound),
        MatchActionError.ownProject => MatchActionEvent(
            MatchActionEventKind.error, AiMatchStrings.errOwnProject),
        MatchActionError.projectClosed => MatchActionEvent(
            MatchActionEventKind.error, AiMatchStrings.errProjectClosed),
        MatchActionError.alreadyRequested => MatchActionEvent(
            MatchActionEventKind.error, AiMatchStrings.errAlreadyRequested),
      };
    }
    return MatchActionEvent(
        MatchActionEventKind.error, AiMatchStrings.genericError);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
