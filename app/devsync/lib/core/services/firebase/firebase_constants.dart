/// Firestore names. The values must match docs/schema.md exactly.
abstract final class FirebaseConstants {
  // ================= Collections =================

  static const String usersCollection = 'users';
  static const String userPrivateCollection = 'userPrivate';
  static const String publicIdsCollection = 'publicIds';
  static const String projectsCollection = 'projects';
  static const String requestsCollection = 'requests';
  static const String invitationsCollection = 'invitations';
  static const String teamsCollection = 'teams';
  static const String matchesCollection = 'matches';
  static const String feedbackCollection = 'feedback';
  static const String promptsCollection = 'prompts';
  static const String configCollection = 'config';
  static const String aiUsageCollection = 'aiUsage';
  static const String notificationsCollection = 'notifications';

  // ================= Subcollections =================

  static const String githubDataCollection = 'githubData';
  static const String detectedSkillsCollection = 'detectedSkills';
  static const String savedCollection = 'saved';
  static const String interestsCollection = 'interests';
  static const String membersCollection = 'members';
  static const String tasksCollection = 'tasks';
  static const String messagesCollection = 'messages';
  static const String matchItemsCollection = 'items';
  static const String notificationItemsCollection = 'items';

  // ================= Fixed Document IDs =================

  static const String githubDataDoc = 'latest';
  static const String promptsConfigDoc = 'prompts';

  // ================= Composite Document IDs =================

  static String requestDocId(String projectId, String applicantId) =>
      '${projectId}_$applicantId';

  static String invitationDocId(String projectId, String inviteeId) =>
      '${projectId}_$inviteeId';

  // ================= Common Fields =================

  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldPublicId = 'publicId';
  static const String fieldTrack = 'track';
  static const String fieldLevel = 'level';
  static const String fieldTitle = 'title';
  static const String fieldDescription = 'description';
  static const String fieldStatus = 'status';
  static const String fieldMessage = 'message';
  static const String fieldProjectId = 'projectId';
  static const String fieldProjectTitle = 'projectTitle';
  static const String fieldOwnerId = 'ownerId';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';

  // ================= User Fields =================

  static const String fieldBio = 'bio';
  static const String fieldLanguages = 'languages';
  static const String fieldSkills = 'skills';
  static const String fieldSoftSkills = 'softSkills';
  static const String fieldInterests = 'interests';
  static const String fieldBackground = 'background';
  static const String fieldGoalText = 'goalText';
  static const String fieldCvUrl = 'cvUrl';
  static const String fieldCvFileName = 'cvFileName';
  static const String fieldCvUpdatedAt = 'cvUpdatedAt';
  static const String fieldPortfolioUrl = 'portfolioUrl';
  static const String fieldLinkedinUrl = 'linkedinUrl';
  static const String fieldBehanceUrl = 'behanceUrl';
  static const String fieldGithubUsername = 'githubUsername';
  static const String fieldGithubConnected = 'githubConnected';

  // ================= Language and Skill Fields =================

  static const String fieldSkillSource = 'source';

  // ================= User Private Fields =================

  static const String fieldEmail = 'email';
  static const String fieldBannerDismissedAt = 'bannerDismissedAt';

  // ================= GitHub Data Fields =================

  static const String fieldReposCount = 'reposCount';
  static const String fieldReposSummary = 'reposSummary';
  static const String fieldRepoLanguage = 'language';
  static const String fieldRepoTopics = 'topics';
  static const String fieldRepoPushedAt = 'pushedAt';
  static const String fieldLanguageShare = 'share';
  static const String fieldActivity = 'activity';
  static const String fieldLastActive = 'lastActive';
  static const String fieldLastSync = 'lastSync';

  // ================= Detected Skill Fields =================

  static const String fieldSkill = 'skill';
  static const String fieldConfidence = 'confidence';
  static const String fieldEvidence = 'evidence';
  static const String fieldReviewedAt = 'reviewedAt';

  // ================= Saved Fields =================

  static const String fieldSavedAt = 'savedAt';

  // ================= Project Fields =================

  static const String fieldPurpose = 'purpose';
  static const String fieldDifficulty = 'difficulty';
  static const String fieldOwnerSnapshot = 'ownerSnapshot';
  static const String fieldOwnerTrack = 'ownerTrack';
  static const String fieldTracks = 'tracks';
  static const String fieldTrackKeys = 'trackKeys';
  static const String fieldOpenTrackKeys = 'openTrackKeys';
  static const String fieldTeamSize = 'teamSize';
  static const String fieldFilledCount = 'filledCount';
  static const String fieldTechStack = 'techStack';
  static const String fieldCommitmentHours = 'commitmentHoursPerWeek';
  static const String fieldMinLevel = 'minLevel';
  static const String fieldExpectedEndDate = 'expectedEndDate';
  static const String fieldMentoring = 'mentoring';
  static const String fieldDraftInvites = 'draftInvites';
  static const String fieldPublishedAt = 'publishedAt';

  // ================= Track Slot Fields =================

  static const String fieldSlotCount = 'count';
  static const String fieldSlotFilled = 'filled';
  static const String fieldSlotSkills = 'skills';

  // ================= Request Fields =================

  static const String fieldApplicantId = 'applicantId';
  static const String fieldPitch = 'pitch';
  static const String fieldApplicantSnapshot = 'applicantSnapshot';
  static const String fieldDecidedAt = 'decidedAt';

  // ================= Invitation Fields =================

  static const String fieldInviteeId = 'inviteeId';
  static const String fieldInviteeSnapshot = 'inviteeSnapshot';
  static const String fieldRespondedAt = 'respondedAt';

  // ================= Team Fields =================

  static const String fieldMemberIds = 'memberIds';

  // ================= Team Member Fields =================

  static const String fieldIsOwner = 'isOwner';
  static const String fieldJoinedVia = 'joinedVia';
  static const String fieldJoinedAt = 'joinedAt';

  // ================= Task Fields =================

  static const String fieldTaskAssigneeId = 'assigneeId';
  static const String fieldTaskPriority = 'priority';
  static const String fieldTaskDeadline = 'deadline';
  static const String fieldTaskCreatedBy = 'createdBy';

  // ================= Team Message Fields =================

  static const String fieldSenderId = 'senderId';
  static const String fieldSenderName = 'senderName';
  static const String fieldText = 'text';

  // ================= Match Fields =================

  static const String fieldScore = 'score';
  static const String fieldMatchedSkills = 'matchedSkills';
  static const String fieldMissingSkills = 'missingSkills';
  static const String fieldMatchedTrack = 'matchedTrack';
  static const String fieldExplanation = 'explanation';
  static const String fieldComplementarySkills = 'complementarySkills';
  static const String fieldLearningTips = 'learningTips';
  static const String fieldTip = 'tip';
  static const String fieldMatchSource = 'source';
  static const String fieldPromptVersion = 'promptVersion';

  // ================= Feedback Fields =================

  static const String fieldKind = 'kind';
  static const String fieldHelpful = 'helpful';
  static const String fieldClarity = 'clarity';
  static const String fieldReason = 'reason';

  // ================= Prompt and Config Fields =================

  static const String fieldTemplate = 'template';
  static const String fieldNotes = 'notes';
  static const String fieldActiveVersion = 'activeVersion';

  // ================= AI Usage Fields =================

  static const String fieldDate = 'date';
  static const String fieldCount = 'count';

  // ================= Notification Fields =================

  static const String fieldType = 'type';
  static const String fieldRefId = 'refId';
  static const String fieldBody = 'body';
  static const String fieldRead = 'read';

  // ================= Cloudinary Folders =================

  static const String cloudinaryAvatarsFolder = 'avatars';
  static const String cloudinaryCvsFolder = 'cvs';
}