import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:equatable/equatable.dart';

// Step 1 project draft data.
class ProjectDraft extends Equatable {
  const ProjectDraft({
    this.title = '',
    this.description = '',
    this.purpose = ProjectPurpose.real,
    this.difficulty = ProjectDifficulty.intermediate,
    this.minLevel = UserLevel.beginner,
    this.ownerTrack = UserTrack.mobile,
    this.commitmentHoursPerWeek = 10,
    this.expectedEndDate,
    this.mentoring = false,
  });

  static const int minTitleLength = 3;
  static const int maxTitleLength = 80;
  static const int minDescriptionLength = 10;
  static const int maxDescription = 300;

  final String title;
  final String description;
  final ProjectPurpose purpose;
  final ProjectDifficulty difficulty;
  final UserLevel minLevel;
  final UserTrack ownerTrack;
  final int commitmentHoursPerWeek;
  final DateTime? expectedEndDate;
  final bool mentoring;

  // Missing required fields.
  List<String> get missing => [
        if (title.trim().length < minTitleLength) 'title',
        if (description.trim().length < minDescriptionLength) 'description',
      ];

  bool get isValid => missing.isEmpty;

  ProjectDraft copyWith({
    String? title,
    String? description,
    ProjectPurpose? purpose,
    ProjectDifficulty? difficulty,
    UserLevel? minLevel,
    UserTrack? ownerTrack,
    int? commitmentHoursPerWeek,
    DateTime? expectedEndDate,
    bool clearExpectedEndDate = false,
    bool? mentoring,
  }) =>
      ProjectDraft(
        title: title ?? this.title,
        description: description ?? this.description,
        purpose: purpose ?? this.purpose,
        difficulty: difficulty ?? this.difficulty,
        minLevel: minLevel ?? this.minLevel,
        ownerTrack: ownerTrack ?? this.ownerTrack,
        commitmentHoursPerWeek:
            commitmentHoursPerWeek ?? this.commitmentHoursPerWeek,
        expectedEndDate: clearExpectedEndDate
            ? null
            : (expectedEndDate ?? this.expectedEndDate),
        mentoring: mentoring ?? this.mentoring,
      );

  @override
  List<Object?> get props => [
        title,
        description,
        purpose,
        difficulty,
        minLevel,
        ownerTrack,
        commitmentHoursPerWeek,
        expectedEndDate,
        mentoring,
      ];
}
