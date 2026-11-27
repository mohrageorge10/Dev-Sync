// Project lifecycle state: active (ongoing), saved draft, or completed/archived (previous).
enum ProjectType { ongoing, draft, previous }

// Structured Git & collaboration rules for a project repository.
class GitWorkflowRules {
  const GitWorkflowRules({
    this.requireFeatureBranches = true,
    this.branchPrefix = 'feature/<name>',
    this.blockDirectMainMerge = true,
    this.requirePrReview = true,
    this.customRules = const [],
  });

  final bool requireFeatureBranches;
  final String branchPrefix;
  final bool blockDirectMainMerge;
  final bool requirePrReview;
  final List<String> customRules;

  // Human-readable active rule statements displayed on Project Overview.
  List<String> get activeRuleLines => [
    if (requireFeatureBranches)
      'Create a dedicated branch for each task ($branchPrefix)',
    if (blockDirectMainMerge)
      'No direct push or merge to main / develop branches',
    if (requirePrReview)
      'Open a Pull Request and get Owner review before merging',
    ...customRules,
  ];

  GitWorkflowRules copyWith({
    bool? requireFeatureBranches,
    String? branchPrefix,
    bool? blockDirectMainMerge,
    bool? requirePrReview,
    List<String>? customRules,
  }) => GitWorkflowRules(
    requireFeatureBranches:
        requireFeatureBranches ?? this.requireFeatureBranches,
    branchPrefix: branchPrefix ?? this.branchPrefix,
    blockDirectMainMerge: blockDirectMainMerge ?? this.blockDirectMainMerge,
    requirePrReview: requirePrReview ?? this.requirePrReview,
    customRules: customRules ?? this.customRules,
  );

  Map<String, dynamic> toMap() => {
    'requireFeatureBranches': requireFeatureBranches,
    'branchPrefix': branchPrefix,
    'blockDirectMainMerge': blockDirectMainMerge,
    'requirePrReview': requirePrReview,
    'customRules': customRules,
  };

  factory GitWorkflowRules.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GitWorkflowRules();
    final rawCustom = map['customRules'];
    return GitWorkflowRules(
      requireFeatureBranches: map['requireFeatureBranches'] as bool? ?? true,
      branchPrefix: (map['branchPrefix'] ?? 'feature/<name>').toString(),
      blockDirectMainMerge: map['blockDirectMainMerge'] as bool? ?? true,
      requirePrReview: map['requirePrReview'] as bool? ?? true,
      customRules: rawCustom is Iterable
          ? rawCustom
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
    );
  }
}

// Project summary model used across My Projects screens.
class ProjectModel {
  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.statusText,
    required this.isOwner,
    required this.membersCount,
    required this.totalSeats,
    required this.tags,
    required this.openRoles,
    this.period = '',
    this.type = ProjectType.ongoing,
    this.repoUrl = '',
    this.cloneUrl = '',
    this.defaultBranch = 'develop',
    this.projectCode = '',
    this.gitRules = const GitWorkflowRules(),
  });

  final String id;
  final String projectCode;
  String name;
  String description;
  String statusText;
  final bool isOwner;
  int membersCount;
  int totalSeats;
  List<String> tags;
  List<String> openRoles;
  final String period;
  ProjectType type;
  String repoUrl;
  String cloneUrl;
  String defaultBranch;
  GitWorkflowRules gitRules;

  // Derived git clone command for 1-tap clipboard copy.
  String get cloneCommand {
    final target = cloneUrl.trim().isNotEmpty
        ? cloneUrl.trim()
        : deriveCloneUrl(repoUrl);
    return target.isEmpty ? '' : 'git clone $target';
  }

  static String deriveCloneUrl(String repoUrl) {
    final trimmed = repoUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return '';
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    return normalized.endsWith('.git') ? normalized : '$normalized.git';
  }
}
