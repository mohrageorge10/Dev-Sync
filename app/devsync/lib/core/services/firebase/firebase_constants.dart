class FirebaseConstants {
  // ================= Collections =================
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String tasksCollection = 'tasks';
  static const String requestsCollection = 'requests';
  static const String promptFeedbackCollection = 'prompt_feedback';

  // ================= User Fields =================
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldProfilePic = 'profile_picture';
  static const String fieldCity = 'city';
  static const String fieldLevel = 'level';
  static const String fieldMainTrack = 'main_track';
  static const String fieldEducation = 'education';
  static const String fieldProgrammingLanguages = 'programming_languages';
  static const String fieldLinkedin = 'linkedin';
  static const String fieldPortfolio = 'portfolio';
  static const String fieldGithubUsername = 'github_username';
  static const String fieldBehance = 'behance';
  static const String fieldCreatedAt = 'created_at';

  // ================= Project Fields =================
  static const String fieldProjectId = 'project_id';
  static const String fieldProjectTitle = 'title';
  static const String fieldProjectDescription = 'description';
  static const String fieldTechStack = 'tech_stack';
  static const String fieldNeededRoles = 'needed_roles';
  static const String fieldProjectDifficulty = 'difficulty';
  static const String fieldProjectType = 'project_type';
  static const String fieldProjectOwnerId = 'owner_id';
  static const String fieldTeamMembers = 'team_members';

  // ================= Task Fields =================
  static const String fieldTaskId = 'task_id';
  static const String fieldTaskTitle = 'task_title';
  static const String fieldTaskDescription = 'task_description';
  static const String fieldTaskAssigneeId = 'assignee_id';
  static const String fieldTaskStatus = 'task_status';

  // ================= Request Fields =================
  static const String fieldRequestId = 'request_id';
  static const String fieldSenderId = 'sender_id';
  static const String fieldReceiverId = 'receiver_id';
  static const String fieldRequestStatus = 'request_status'; // pending, accepted, declined

  // ================= Storage Paths =================
  static const String profileImagesPath = 'profile_images/';
  static const String wardrobeImagesPath = 'wardrobe_images/';
  static const String projectFilesPath = 'project_files/';
}