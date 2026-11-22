import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:equatable/equatable.dart';

/// User rating of one AI recommendation (saved in `feedback`).
class MatchFeedback extends Equatable {
  const MatchFeedback({
    required this.projectId,
    required this.helpful,
    required this.clarity,
    this.kind = FeedbackKind.match,
    this.reasons = const [],
    this.comment = '',
  });

  final String projectId;
  final bool helpful;

  /// 1..5 stars for how clear the explanation was (0 = not rated).
  final int clarity;
  final FeedbackKind kind;

  /// "What wasn't quite right?" chips (only when not helpful).
  final List<String> reasons;
  final String comment;

  @override
  List<Object?> get props =>
      [projectId, helpful, clarity, kind, reasons, comment];
}
