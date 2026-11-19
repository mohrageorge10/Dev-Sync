import 'dart:math';

import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/team_limits.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 2 team formation cubit.
class TeamCubit extends Cubit<TeamState> {
  TeamCubit() : super(const TeamState());

  TeamTrack? _removed;
  int _removedIndex = 0;

  void _replace(TeamTrack t) => emit(
        TeamState(
          tracks: [
            for (final x in state.tracks)
              x.definition.id == t.definition.id ? t : x,
          ],
        ),
      );

  // Add or update a track slot.
  String? upsertTrack(
    String id, {
    required int people,
    required Set<String> skills,
  }) {
    final existing = state.byId(id);
    final others = state.totalPeople - (existing?.people ?? 0);
    if (others + people > TeamLimits.maxTeam - 1) {
      return 'Team is limited to ${TeamLimits.maxTeam} members (including you).';
    }

    if (existing == null) {
      emit(
        TeamState(
          tracks: [
            ...state.tracks,
            TeamTrack(
              definition: TrackCatalog.byId(id),
              people: people,
              skills: {...skills},
            ),
          ],
        ),
      );
    } else {
      _replace(
        existing.copyWith(
          people: max(people, existing.invites.length),
          skills: {...skills},
        ),
      );
    }
    return null;
  }

  // Update track headcount.
  String? setPeople(String id, int n) {
    final t = state.byId(id);
    if (t == null) return null;
    if (n < t.invites.length) {
      return 'Cancel an invite before reducing headcount.';
    }
    if (n > TeamLimits.maxPerTrack) {
      return 'Max ${TeamLimits.maxPerTrack} people per track.';
    }
    if (state.totalPeople - t.people + n > TeamLimits.maxTeam - 1) {
      return 'Team is limited to ${TeamLimits.maxTeam} members (including you).';
    }
    _replace(t.copyWith(people: n));
    return null;
  }

  // Toggle track skill.
  void toggleSkill(String id, String skill) {
    final t = state.byId(id);
    if (t == null) return;
    final next = {...t.skills};
    next.contains(skill) ? next.remove(skill) : next.add(skill);
    _replace(t.copyWith(skills: next));
  }

  // Remove track with undo support.
  void removeTrack(String id) {
    final i = state.tracks.indexWhere((t) => t.definition.id == id);
    if (i < 0) return;
    _removed = state.tracks[i];
    _removedIndex = i;
    emit(TeamState(tracks: [...state.tracks]..removeAt(i)));
  }

  bool undoRemove() {
    final t = _removed;
    if (t == null) return false;
    final list = [...state.tracks]
      ..insert(min(_removedIndex, state.tracks.length), t);
    emit(TeamState(tracks: list));
    _removed = null;
    return true;
  }

  // Queue developer invitation.
  String? invite(DevBuilder b, String? trackId, {String message = ''}) {
    final t = trackId == null ? null : state.byId(trackId);
    if (t == null) return 'Choose a track slot first.';
    if (t.openSpots <= 0) return 'No open spots left in ${t.definition.name}.';
    if (state.tracks.any((x) => x.invites.any((i) => i.builder.id == b.id))) {
      return '${b.name} is already invited.';
    }
    _replace(
      t.copyWith(invites: [...t.invites, Invite(b, message: message.trim())]),
    );
    return null;
  }

  // Cancel queued invitation.
  void cancelInvite(String trackId, String builderId) {
    final t = state.byId(trackId);
    if (t == null) return;
    _replace(
      t.copyWith(
        invites: t.invites.where((i) => i.builder.id != builderId).toList(),
      ),
    );
  }

  // Suggest up to 3 complementary tracks.
  List<TrackDefinition> suggestedTracks(ProjectDraft d) {
    final used = {
      d.ownerTrack.name,
      ...state.tracks.map((t) => t.definition.id),
    };
    final order = <UserTrack>[
      d.ownerTrack == UserTrack.backend ? UserTrack.mobile : UserTrack.backend,
      UserTrack.uiux,
      UserTrack.web,
      UserTrack.mobile,
      if (d.purpose == ProjectPurpose.real) ...[UserTrack.qa, UserTrack.devops],
      UserTrack.ai,
      UserTrack.data,
    ];

    final out = <String>[];
    for (final t in order) {
      if (!used.contains(t.name) && !out.contains(t.name)) out.add(t.name);
    }
    return out.take(3).map(TrackCatalog.byId).toList();
  }

  // Team gap warnings.
  List<String> warnings(ProjectDraft d) {
    final tracks = state.tracks;
    final ids = {d.ownerTrack.name, ...tracks.map((t) => t.definition.id)};
    final noSkills = tracks.where((t) => t.skills.isEmpty).firstOrNull;

    return [
      if (tracks.isNotEmpty && !ids.contains(UserTrack.uiux.name))
        'No UI/UX track yet. Consider adding one so the product is well-designed.',
      if (d.purpose == ProjectPurpose.real &&
          tracks.isNotEmpty &&
          !ids.contains(UserTrack.qa.name))
        'Real-world projects benefit from a QA Engineering track.',
      if (noSkills != null)
        'Add specific skills to ${noSkills.definition.name} for better matches.',
      if (state.totalPeople >= TeamLimits.maxTeam - 1)
        'Team size limit reached (${TeamLimits.maxTeam} total members).',
    ];
  }

  void reset() {
    _removed = null;
    emit(const TeamState());
  }
}
