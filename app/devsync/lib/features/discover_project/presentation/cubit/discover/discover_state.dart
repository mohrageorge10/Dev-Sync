import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:equatable/equatable.dart';

// Unified state for discover home, guest mode, search, filters, and public profile.
class DiscoverState extends Equatable {
  const DiscoverState({
    this.isLoading = false,
    this.currentUserId,
    this.userName = 'Alex',
    this.profileStrength = 0.6,
    this.userTrack,
    this.userSkills = const [],
    this.isBoostDismissed = false,
    this.tab = 0,
    this.searchQuery = '',
    this.filters = const FilterState(),
    this.sort = 'Recommended',
    this.guestSelectedSkill = 'All Stacks',
    this.guestSearchQuery = '',
    this.allProjects = const [],
    this.allDevelopers = const [],
    this.appliedProjectIds = const {},
    this.savedProjectIds = const {},
    this.savedDeveloperIds = const {},
    this.invitedDeveloperIds = const {},
  });

  final bool isLoading;
  final String? currentUserId;
  final String userName;
  final double profileStrength;
  final String? userTrack;
  final List<String> userSkills;
  final bool isBoostDismissed;
  final int tab;
  final String searchQuery;
  final FilterState filters;
  final String sort;
  final String guestSelectedSkill;
  final String guestSearchQuery;
  final List<ProjectModel> allProjects;
  final List<DeveloperModel> allDevelopers;
  final Set<String> appliedProjectIds;
  final Set<String> savedProjectIds;
  final Set<String> savedDeveloperIds;
  final Set<String> invitedDeveloperIds;

  // Time-of-day greeting for logged-in home header.
  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool get showBoost => !isBoostDismissed && profileStrength < 1.0;

  bool get isProjectsTab => tab == 0;

  // Check if current user can apply to a project (not owner + open + matches track or skills).
  bool canApplyTo(ProjectModel project) {
    if (currentUserId != null &&
        currentUserId!.isNotEmpty &&
        project.ownerId == currentUserId) {
      return false;
    }
    return project.isEligibleFor(userTrack: userTrack, userSkills: userSkills);
  }

  // Eligible projects for current user.
  List<ProjectModel> get eligibleProjects =>
      allProjects.where(canApplyTo).toList();

  // Dynamic badge and search hint per active tab.
  String get headerBadge => isProjectsTab
      ? '${eligibleProjects.length} Open Builds'
      : '${allDevelopers.length} Available';

  String get searchHint => isProjectsTab
      ? 'Search projects by title, stack, or role'
      : 'Search developers by skill, @handle, or track...';

  // Top recommended open projects eligible for current user.
  List<ProjectModel> get recommendedProjects {
    final open = [...eligibleProjects]
      ..sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return open.take(3).toList();
  }

  // Top recommended developers for logged-in home feed.
  List<DeveloperModel> get recommendedDevelopers {
    final list = [...allDevelopers]
      ..sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return list.take(3).toList();
  }

  // Guest mode filtered projects.
  List<ProjectModel> get guestProjects => allProjects
      .where(
        (p) =>
            p.matchesSkillChip(guestSelectedSkill) &&
            p.matchesQuery(guestSearchQuery),
      )
      .toList();

  // Guest mode filtered developers.
  List<DeveloperModel> get guestDevelopers => allDevelopers
      .where(
        (d) =>
            d.matchesSkillChip(guestSelectedSkill) &&
            d.matchesQuery(guestSearchQuery),
      )
      .toList();

  // Filter eligible projects and developers on search screen.
  List<ProjectModel> filterProjects(FilterState f) {
    final source = f.showOpen ? eligibleProjects : allProjects;
    return source
        .where((p) => p.matches(f) && p.matchesQuery(searchQuery))
        .toList();
  }

  List<DeveloperModel> filterDevelopers(FilterState f) => allDevelopers
      .where((d) => d.matches(f) && d.matchesQuery(searchQuery))
      .toList();

  // Filtered and sorted projects list on search screen.
  List<ProjectModel> get projects {
    final list = filterProjects(filters);
    if (sort == 'Best Match') {
      list.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    } else if (sort == 'Newest') {
      list.sort((a, b) => a.ageHours.compareTo(b.ageHours));
    }
    return list;
  }

  // Filtered and sorted developers list on search screen.
  List<DeveloperModel> get developers {
    final list = filterDevelopers(filters);
    if (sort == 'Best Match') {
      list.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    }
    return list;
  }

  bool isProjectSaved(String id) => savedProjectIds.contains(id);
  bool isProjectApplied(String id) => appliedProjectIds.contains(id);
  bool isDeveloperSaved(String id) => savedDeveloperIds.contains(id);
  bool isDeveloperInvited(String id) => invitedDeveloperIds.contains(id);

  // Projects owned by current user that are open and match the developer's track or skills.
  List<ProjectModel> ownedProjectsForDeveloper(DeveloperModel developer) {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return const [];
    return allProjects
        .where(
          (p) =>
              p.ownerId == uid &&
              p.isEligibleFor(
                userTrack: developer.role,
                userSkills: developer.skills,
              ),
        )
        .toList();
  }

  // Projects owned by current user.
  List<ProjectModel> get ownedProjects {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return const [];
    return allProjects.where((p) => p.ownerId == uid).toList();
  }

  // Saved projects and developers lists.
  List<ProjectModel> get savedProjects =>
      allProjects.where((p) => savedProjectIds.contains(p.id)).toList();

  List<DeveloperModel> get savedDevelopers =>
      allDevelopers.where((d) => savedDeveloperIds.contains(d.id)).toList();

  DiscoverState copyWith({
    bool? isLoading,
    String? currentUserId,
    String? userName,
    double? profileStrength,
    String? userTrack,
    List<String>? userSkills,
    bool? isBoostDismissed,
    int? tab,
    String? searchQuery,
    FilterState? filters,
    String? sort,
    String? guestSelectedSkill,
    String? guestSearchQuery,
    List<ProjectModel>? allProjects,
    List<DeveloperModel>? allDevelopers,
    Set<String>? appliedProjectIds,
    Set<String>? savedProjectIds,
    Set<String>? savedDeveloperIds,
    Set<String>? invitedDeveloperIds,
  }) => DiscoverState(
    isLoading: isLoading ?? this.isLoading,
    currentUserId: currentUserId ?? this.currentUserId,
    userName: userName ?? this.userName,
    profileStrength: profileStrength ?? this.profileStrength,
    userTrack: userTrack ?? this.userTrack,
    userSkills: userSkills ?? this.userSkills,
    isBoostDismissed: isBoostDismissed ?? this.isBoostDismissed,
    tab: tab ?? this.tab,
    searchQuery: searchQuery ?? this.searchQuery,
    filters: filters ?? this.filters,
    sort: sort ?? this.sort,
    guestSelectedSkill: guestSelectedSkill ?? this.guestSelectedSkill,
    guestSearchQuery: guestSearchQuery ?? this.guestSearchQuery,
    allProjects: allProjects ?? this.allProjects,
    allDevelopers: allDevelopers ?? this.allDevelopers,
    appliedProjectIds: appliedProjectIds ?? this.appliedProjectIds,
    savedProjectIds: savedProjectIds ?? this.savedProjectIds,
    savedDeveloperIds: savedDeveloperIds ?? this.savedDeveloperIds,
    invitedDeveloperIds: invitedDeveloperIds ?? this.invitedDeveloperIds,
  );

  @override
  List<Object?> get props => [
    isLoading,
    currentUserId,
    userName,
    profileStrength,
    userTrack,
    userSkills,
    isBoostDismissed,
    tab,
    searchQuery,
    filters,
    sort,
    guestSelectedSkill,
    guestSearchQuery,
    allProjects,
    allDevelopers,
    appliedProjectIds,
    savedProjectIds,
    savedDeveloperIds,
    invitedDeveloperIds,
  ];
}
