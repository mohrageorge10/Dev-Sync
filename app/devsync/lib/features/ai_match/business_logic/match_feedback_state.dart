abstract class MatchFeedbackState {
  const MatchFeedbackState();
}

class MatchFeedbackInitial extends MatchFeedbackState {
  const MatchFeedbackInitial();
}

class MatchFeedbackSubmitting extends MatchFeedbackState {
  const MatchFeedbackSubmitting();
}

class MatchFeedbackSuccess extends MatchFeedbackState {
  const MatchFeedbackSuccess();
}

class MatchFeedbackError extends MatchFeedbackState {
  final String message;
  const MatchFeedbackError(this.message);
}
