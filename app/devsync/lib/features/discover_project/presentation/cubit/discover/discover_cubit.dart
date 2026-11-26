import 'dart:async';

import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/developers_data.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/data/model/projects_data.dart';
import 'package:devsync/features/discover_project/data/repositories/discover_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'discover_state.dart';

// Unified cubit managing projects, developers, filters, bookmarks, applications, and invites.
class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({int initialTab = 0, DiscoverRepository? repository})
      : _repo = repository ??
            (ServiceLocator.isRegistered<DiscoverRepository>()
                ? ServiceLocator.get<DiscoverRepository>()
                : null),
        super(
          DiscoverState(
            tab: initialTab,
            allProjects: projectsData,
            allDevelopers: developersData,
          ),
        ) {
    loadData();
  }

  final DiscoverRepository? _repo;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  Timer? _guestDebounce;

  // Load user summary, projects, developers, and saved IDs from Firestore.
  Future<void> loadData() async {
    final repo = _repo;
    if (repo == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        repo.fetchUserSummary(),
        repo.fetchProjects(),
        repo.fetchDevelopers(),
        repo.fetchSavedIds(),
        repo.fetchAppliedProjectIds(),
        repo.fetchInvitedDeveloperIds(),
      ]);
      if (isClosed) return;
      final summary = results[0] as ({
        String userName,
        double profileStrength,
        String? userTrack,
        List<String> secondaryTracks,
        List<String> userSkills,
      });
      final projects = results[1] as List<dynamic>;
      final devs = results[2] as List<dynamic>;
      final saved = results[3] as Set<String>;
      final applied = results[4] as Set<String>;
      final invited = results[5] as Set<String>;

      emit(
        state.copyWith(
          isLoading: false,
          currentUserId: repo.currentUserId,
          userName: summary.userName,
          profileStrength: summary.profileStrength,
          userTrack: summary.userTrack,
          secondaryTracks: summary.secondaryTracks,
          userSkills: summary.userSkills,
          allProjects: projects.cast(),
          allDevelopers: devs.cast(),
          savedProjectIds: saved,
          savedDeveloperIds: saved,
          appliedProjectIds: applied,
          invitedDeveloperIds: invited,
        ),
      );
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isLoading: false));
    }
  }

  // Reset user-scoped state on sign-out.
  void reset() {
    _debounce?.cancel();
    _guestDebounce?.cancel();
    searchController.clear();
    emit(
      DiscoverState(
        allProjects: state.allProjects,
        allDevelopers: state.allDevelopers,
      ),
    );
  }

  // Dismiss profile completion boost card.
  void dismissBoost() => emit(state.copyWith(isBoostDismissed: true));

  // Switch active search tab (0 = Projects, 1 = Developers).
  void setTab(int index) => emit(state.copyWith(tab: index));

  // Debounced search on SearchScreen.
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!isClosed) emit(state.copyWith(searchQuery: query.trim()));
    });
  }

  // Guest mode stack chip filter.
  void setGuestSkill(String skill) =>
      emit(state.copyWith(guestSelectedSkill: skill));

  // Debounced guest mode search.
  void searchGuest(String query) {
    _guestDebounce?.cancel();
    _guestDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!isClosed) emit(state.copyWith(guestSearchQuery: query.trim()));
    });
  }

  void setSort(String sort) => emit(state.copyWith(sort: sort));

  void applyFilters(FilterState filters) =>
      emit(state.copyWith(filters: filters.copyWith(skillsQuery: '')));

  void removeFilter(String value) =>
      emit(state.copyWith(filters: state.filters.without(value)));

  void clearFilters() => emit(state.copyWith(filters: const FilterState()));

  void resetAll() {
    _debounce?.cancel();
    searchController.clear();
    emit(state.copyWith(searchQuery: '', filters: const FilterState()));
  }

  // Count matching items for filter draft.
  int countMatching(FilterState draft) => state.isProjectsTab
      ? state.filterProjects(draft).length
      : state.filterDevelopers(draft).length;

  // Apply to project and persist request in Firestore.
  Future<void> applyToProject(String id) async {
    if (state.appliedProjectIds.contains(id)) return;
    emit(state.copyWith(appliedProjectIds: {...state.appliedProjectIds, id}));
    final project = state.allProjects.where((p) => p.id == id).firstOrNull;
    await _repo?.applyToProject(id, projectTitle: project?.title);
  }

  // Withdraw project application and remove request from Firestore.
  Future<void> cancelApplication(String id) async {
    if (!state.appliedProjectIds.contains(id)) return;
    final updated = {...state.appliedProjectIds}..remove(id);
    emit(state.copyWith(appliedProjectIds: updated));
    await _repo?.cancelApplication(id);
  }

  // Toggle saved project bookmark.
  Future<void> toggleProjectSaved(String id) async {
    emit(state.copyWith(savedProjectIds: _toggled(state.savedProjectIds, id)));
    await _repo?.toggleSaved(id, kind: 'project');
  }

  // Toggle saved developer bookmark.
  Future<void> toggleDeveloperSaved(String id) async {
    emit(
      state.copyWith(savedDeveloperIds: _toggled(state.savedDeveloperIds, id)),
    );
    await _repo?.toggleSaved(id, kind: 'developer');
  }

  // Invite a developer to a specific owned project and persist in Firestore.
  Future<void> inviteDeveloper({
    required DeveloperModel developer,
    required ProjectModel project,
  }) async {
    emit(
      state.copyWith(
        invitedDeveloperIds: {...state.invitedDeveloperIds, developer.id},
      ),
    );
    await _repo?.inviteDeveloper(developer: developer, project: project);
  }

  Set<String> _toggled(Set<String> set, String id) =>
      set.contains(id) ? ({...set}..remove(id)) : {...set, id};

  @override
  Future<void> close() {
    _debounce?.cancel();
    _guestDebounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
