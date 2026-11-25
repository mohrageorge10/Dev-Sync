class AppRoutes {
  AppRoutes._();
  static const String splash = '/splash';
  static const String onBoarding = '/on-boarding';

  // ============== Auth ===============
  static const String authEntry = '/auth-entry';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String checkInbox = '/check-inbox';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';

  // ============== Discover & Main ===============
  static const String main = '/main';
  static const String discoverGuest = '/discover-guest';
  static const String discoverSearch = '/discover-search';
  static const String publicProfile = '/public-profile';
  static const String projectDetails = '/project-details';

  // ============== Create Project ===============
  static const String createProject = '/create-project';

  // ============== Profile ===============
  static const String profileEdit = '/profile/edit';
  static const String profileBasicInfo = '/profile/basic-info';
  static const String profileTechnical = '/profile/technical';
  static const String profileSkills = '/profile/skills';
  static const String profileProjects = '/profile/projects';
  static const String profileConnectWork = '/profile/connect-work';
  static const String profileComplete = '/profile/complete';
  static const String profileSnapshot = '/profile/snapshot';
  static const String profileGithubConnect = '/profile/github/connect';
  static const String profileGithubAnalysis = '/profile/github/analysis';
  static const String profileGithubReview = '/profile/github/review';
  static const String profileCvViewer = '/profile/cv-viewer';

  // ============== My Teams ===============
  static const String myTeams = '/my-teams';
  static const String teamWorkspace = '/team-workspace';
  static const String teamSettings = '/team-settings';
  static const String taskBoard = '/task-board';
  static const String teamMembers = '/team-members';
  static const String taskDetails = '/task-details';
  static const String taskCreate = '/task-create';
  static const String taskEdit = '/task-edit';
}
