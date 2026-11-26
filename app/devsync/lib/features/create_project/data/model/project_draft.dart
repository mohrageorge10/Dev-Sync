import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:equatable/equatable.dart';

// Step 1 project draft data including optional repository and Git rules.
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
    this.repoUrl = '',
    this.cloneUrl = '',
    this.defaultBranch = 'develop',
    this.requireFeatureBranches = true,
    this.branchPrefix = 'feature/<name>',
    this.blockDirectMainMerge = true,
    this.requirePrReview = true,
    this.customRules = const [],
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
  final String repoUrl;
  final String cloneUrl;
  final String defaultBranch;
  final bool requireFeatureBranches;
  final String branchPrefix;
  final bool blockDirectMainMerge;
  final bool requirePrReview;
  final List<String> customRules;

  // Missing required fields.
  List<String> get missing => [
    if (title.trim().length < minTitleLength) 'title',
    if (description.trim().length < minDescriptionLength) 'description',
  ];

  bool get isValid => missing.isEmpty;

  // Auto-derive clone URL from repoUrl if cloneUrl is empty.
  String get effectiveCloneUrl {
    if (cloneUrl.trim().isNotEmpty) return cloneUrl.trim();
    final trimmed = repoUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return '';
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    return normalized.endsWith('.git') ? normalized : '$normalized.git';
  }

  List<String> get activeGitRules => [
    if (requireFeatureBranches) 'Branch per feature ($branchPrefix)',
    if (blockDirectMainMerge) 'No direct push/merge to main or develop',
    if (requirePrReview) 'Pull Request & Owner review required',
    ...customRules,
  ];

  Map<String, dynamic> get gitRulesMap => {
    'requireFeatureBranches': requireFeatureBranches,
    'branchPrefix': branchPrefix.trim().isEmpty
        ? 'feature/<name>'
        : branchPrefix.trim(),
    'blockDirectMainMerge': blockDirectMainMerge,
    'requirePrReview': requirePrReview,
    'customRules': customRules,
  };

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
    String? repoUrl,
    String? cloneUrl,
    String? defaultBranch,
    bool? requireFeatureBranches,
    String? branchPrefix,
    bool? blockDirectMainMerge,
    bool? requirePrReview,
    List<String>? customRules,
  }) => ProjectDraft(
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
    repoUrl: repoUrl ?? this.repoUrl,
    cloneUrl: cloneUrl ?? this.cloneUrl,
    defaultBranch: defaultBranch ?? this.defaultBranch,
    requireFeatureBranches:
        requireFeatureBranches ?? this.requireFeatureBranches,
    branchPrefix: branchPrefix ?? this.branchPrefix,
    blockDirectMainMerge: blockDirectMainMerge ?? this.blockDirectMainMerge,
    requirePrReview: requirePrReview ?? this.requirePrReview,
    customRules: customRules ?? this.customRules,
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
    repoUrl,
    cloneUrl,
    defaultBranch,
    requireFeatureBranches,
    branchPrefix,
    blockDirectMainMerge,
    requirePrReview,
    customRules,
  ];
}
