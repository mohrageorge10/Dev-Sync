import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:flutter/material.dart';

// Purpose labels and icons.
extension ProjectPurposeX on ProjectPurpose {
  String get label =>
      this == ProjectPurpose.learning ? 'Learning' : 'Real-world';

  String get subtitle => this == ProjectPurpose.learning
      ? 'Practice skills, experiment, and learn together'
      : 'Production, startup, open-source, or portfolio product';

  IconData get icon => this == ProjectPurpose.learning
      ? Icons.school_outlined
      : Icons.rocket_launch_outlined;
}

// Difficulty labels.
extension ProjectDifficultyX on ProjectDifficulty {
  String get label => switch (this) {
        ProjectDifficulty.beginner => 'Beginner',
        ProjectDifficulty.junior => 'Junior',
        ProjectDifficulty.intermediate => 'Intermediate',
        ProjectDifficulty.advanced => 'Advanced',
      };
}

// User level labels and parser.
extension UserLevelX on UserLevel {
  String get label => switch (this) {
        UserLevel.beginner => 'Beginner',
        UserLevel.junior => 'Junior',
        UserLevel.intermediate => 'Intermediate',
        UserLevel.advanced => 'Advanced',
      };
}

extension UserLevelParserX on UserLevel {
  static UserLevel fromName(
    String? raw, {
    UserLevel fallback = UserLevel.intermediate,
  }) =>
      UserLevel.values.firstWhere(
        (l) => l.name == raw?.toLowerCase(),
        orElse: () => fallback,
      );
}

// Track labels, icons, and parser.
extension UserTrackX on UserTrack {
  String get label => switch (this) {
        UserTrack.mobile => 'Mobile',
        UserTrack.web => 'Web',
        UserTrack.backend => 'Backend',
        UserTrack.data => 'Data',
        UserTrack.ai => 'AI & ML',
        UserTrack.uiux => 'UI/UX',
        UserTrack.qa => 'QA Eng.',
        UserTrack.devops => 'DevOps',
      };

  IconData get icon => switch (this) {
        UserTrack.mobile => Icons.phone_android_rounded,
        UserTrack.web => Icons.web_rounded,
        UserTrack.backend => Icons.storage_outlined,
        UserTrack.data => Icons.analytics_outlined,
        UserTrack.ai => Icons.psychology_alt_outlined,
        UserTrack.uiux => Icons.draw_outlined,
        UserTrack.qa => Icons.bug_report_outlined,
        UserTrack.devops => Icons.dns_outlined,
      };

  static UserTrack fromName(
    String? raw, {
    UserTrack fallback = UserTrack.mobile,
  }) =>
      UserTrack.values.firstWhere(
        (t) => t.name == raw?.toLowerCase(),
        orElse: () => fallback,
      );
}
