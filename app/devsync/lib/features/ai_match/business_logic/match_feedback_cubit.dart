import 'package:devsync/features/ai_match/business_logic/match_feedback_state.dart';
import 'package:devsync/features/ai_match/data/models/match_feedback.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sends the rating of one recommendation.
class MatchFeedbackCubit extends Cubit<MatchFeedbackState> {
  MatchFeedbackCubit(this._repo) : super(const MatchFeedbackInitial());

  final MatchRepo _repo;

  Future<void> submit(MatchFeedback feedback) async {
    if (state is MatchFeedbackSubmitting) return; // no double submit
    emit(const MatchFeedbackSubmitting());
    try {
      await _repo.submitFeedback(feedback);
      if (!isClosed) emit(const MatchFeedbackSuccess());
    } catch (_) {
      if (!isClosed) emit(const MatchFeedbackError(AiMatchStrings.genericError));
    }
  }
}
