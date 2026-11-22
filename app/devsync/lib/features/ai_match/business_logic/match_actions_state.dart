import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:equatable/equatable.dart';

enum MatchActionEventKind { saved, unsaved, requestSent, error, needsLogin }

/// One-time message for the UI (snack bar or login sheet).
class MatchActionEvent {
  MatchActionEvent(this.kind, [this.message = '']);

  final MatchActionEventKind kind;
  final String message;
}

/// State of the actions of one project: save (bookmark) and join request.
class MatchActionsState extends Equatable {
  const MatchActionsState({
    this.saved = false,
    this.request,
    this.savingBookmark = false,
    this.sendingRequest = false,
    this.event,
  });

  final bool saved;

  /// Status of the user's join request (null = not sent yet).
  final RequestStatus? request;
  final bool savingBookmark;
  final bool sendingRequest;
  final MatchActionEvent? event;

  /// [event] is NOT kept between copies: the UI shows it only once.
  MatchActionsState copyWith({
    bool? saved,
    RequestStatus? request,
    bool? savingBookmark,
    bool? sendingRequest,
    MatchActionEvent? event,
    bool clearRequest = false,
  }) {
    return MatchActionsState(
      saved: saved ?? this.saved,
      // [clearRequest] puts the status back to "not sent yet" (e.g. logout).
      request: clearRequest ? null : (request ?? this.request),
      savingBookmark: savingBookmark ?? this.savingBookmark,
      sendingRequest: sendingRequest ?? this.sendingRequest,
      event: event,
    );
  }

  @override
  List<Object?> get props =>
      [saved, request, savingBookmark, sendingRequest, event];
}
