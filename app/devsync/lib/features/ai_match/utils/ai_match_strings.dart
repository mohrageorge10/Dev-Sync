// Texts used only by the AI Match feature.
// Labels marked (CHECK) were hard to read in the Figma export: compare them with the design.
class AiMatchStrings {
  AiMatchStrings._();

  // Match history
  static const String historyTitle = 'Match History';
  static const String historySubtitle =
      'Projects our AI recommended based on your skills and track.';
  static const String tabAll = 'All Matches'; // (CHECK)
  static const String tabStrong = 'Strong Fits'; // (CHECK)
  static const String sortedBy = 'SORTED BY RELEVANCE'; // (CHECK)
  static const String emptyHistory =
      'No matches yet. Complete your profile to get recommendations.';
  static const String emptyStrong =
      'No strong fits yet. Improve your profile to unlock better matches.';
  static const String bannerTitle = 'Strengthen your matches'; // (CHECK)
  static const String bannerBody =
      'Add more skills and connect GitHub so the AI can recommend better projects.'; // (CHECK)
  static const String completeProfile = 'Complete Profile';
  static const String dismiss = 'Dismiss';
  static const String openProject = 'Open Project';
  static const String whyItFits = 'Why it fits';

  // Why this project fits you
  static const String whyTitle = 'Why This Project Fits You';
  static const String aiAnalysis = 'AI MATCH ANALYSIS';
  static const String matchedSkills = 'Matched Skills';
  static const String matchedSkillsHint =
      'Skills in your profile that this project needs.';
  static const String complementarySkills = 'Complementary Skills';
  static const String complementaryHint =
      'Extra skills you bring that will help the team.';
  static const String skillGaps = 'Skill Gaps';
  static const String skillGapsHint =
      'You can learn these while working on the project.';
  static const String helpfulQuestion = 'Was this match helpful?';
  static const String skip = 'Skip';
  static const String viewSkillGap = 'View Skill Gap';
  static const String requestToJoin = 'Request to Join';

  // Skill gap analysis
  static const String gapTitle = 'Skill Gap Analysis';
  static const String growthTitle = 'Your growth opportunities';
  static const String skillsYouHave = 'Skills You Already Have';
  static const String requirements = 'Project Requirements Breakdown';
  static const String youHave = 'YOU HAVE';
  static const String stillNeeded = 'STILL NEEDED';
  static const String skillsToExplore = 'Skills to Explore & How to Prepare';
  static const String backToProject = 'Back to Project';

  // Rate recommendation sheet
  static const String rateTitle = 'Rate Recommendation Bottom Sheet';
  static const String rateQuestion = 'How was this recommendation?';
  static const String rateSubtitle =
      'Your feedback helps DevSync fine-tune project fit and skill weights.';
  static const String helpful = 'Helpful';
  static const String notGoodFit = 'Not a good fit';
  static const String whatWasWrong = "What wasn't quite right?";
  static const List<String> wrongReasons = [
    'Wrong skills',
    'Too advanced',
    'Too easy',
    'Not interested in topic',
    'Other',
  ];
  static const String clarityQuestion = 'How clear was the explanation?';
  // Caption under the stars (index = stars - 1). Only the 4-star text is
  // from the design (CHECK the others with the designer).
  static const List<String> clarityLabels = [
    'Hard to follow',
    'Somewhat unclear',
    'Fairly clear',
    'Clear and understandable rationale',
    'Very clear and well explained',
  ];
  static const String additionalThoughts = 'Additional thoughts';
  static const String optional = '(optional)';
  static const String additionalHint =
      'What would make matches feel more tailored?';
  static const String submitFeedback = 'Submit Feedback';
  static const String cancel = 'Cancel';
  static const String feedbackThanks = 'Thanks for your feedback!';
  // Project actions (save / share / join)
  static const String savedMsg = 'Saved to your list';
  static const String unsavedMsg = 'Removed from your saved list';
  static const String copiedMsg = 'Copied to clipboard';
  static const String requestSentMsg = 'Request sent to the project team';
  static const String requestSending = 'Sending...';
  static const String requestSent = 'Request Sent';
  static const String requestAccepted = 'Request Accepted';
  static const String requestDeclined = 'Request Declined';
  static const String errProjectNotFound =
      'This project is no longer available.';
  static const String errOwnProject = "You can't join your own project.";
  static const String errProjectClosed =
      'This project is not accepting requests right now.';
  static const String errAlreadyRequested =
      'You already sent a request to this project.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String comingSoon = 'This part is not connected yet.';
}
