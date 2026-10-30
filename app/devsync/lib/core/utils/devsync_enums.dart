// ================= User Enums =================

enum UserTrack {
  mobile,
  web,
  backend,
  data,
  ai,
  uiux,
  qa,
  devops,
}

enum UserLevel {
  beginner,
  junior,
  intermediate,
  advanced,
}

// ================= Project Enums =================

enum ProjectPurpose {
  learning,
  real,
}

enum ProjectDifficulty {
  beginner,
  junior,
  intermediate,
  advanced,
}

enum ProjectStatus {
  draft,
  open,
  full,
  completed,
}

// ================= Request Enums =================

enum RequestStatus {
  pending,
  accepted,
  rejected,
}

// ================= Invitation Enums =================

enum InvitationStatus {
  pending,
  accepted,
  declined,
  cancelled,
}

// ================= Task Enums =================

enum TaskStatus {
  todo,
  inProgress,
  inReview,
  done,
}

enum TaskPriority {
  low,
  medium,
  high,
}

// ================= Detected Skill Enums =================

enum DetectedSkillStatus {
  pending,
  accepted,
  rejected,
}

enum SkillSource {
  manual,
  github,
}

// ================= Match Enums =================

enum MatchSource {
  llm,
  cached,
  fallback,
}

// ================= Feedback Enums =================

enum FeedbackKind {
  match,
  explanation,
  pitch,
  projectSetup,
}