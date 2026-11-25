import 'dart:async';

import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/readiness_item.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/insights/insights_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Live project strength, checklist, and tech stack cubit.
class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({
    required DraftCubit draftCubit,
    required TeamCubit teamCubit,
  })  : _draftCubit = draftCubit,
        _teamCubit = teamCubit,
        super(_compute(draftCubit.state.draft, teamCubit.state.tracks)) {
    _draftSub = _draftCubit.stream.listen((_) => _refresh());
    _teamSub = _teamCubit.stream.listen((_) => _refresh());
  }

  final DraftCubit _draftCubit;
  final TeamCubit _teamCubit;
  late final StreamSubscription<DraftState> _draftSub;
  late final StreamSubscription<TeamState> _teamSub;

  static InsightsState _compute(ProjectDraft d, List<TeamTrack> tracks) =>
      InsightsState(
        strength: _strength(d, tracks),
        tip: _nextTip(d, tracks),
        checklist: _checklist(d, tracks),
        techStack: _techStack(d, tracks),
      );

  // Score 0..100.
  static int _strength(ProjectDraft d, List<TeamTrack> tracks) {
    final desc = d.description.trim().length;
    var s = 0;
    if (d.title.trim().length >= ProjectDraft.minTitleLength) s += 20;
    if (desc >= 40) {
      s += 25;
    } else if (desc >= ProjectDraft.minDescriptionLength) {
      s += 15;
    }
    if (d.expectedEndDate != null) s += 10;
    if (tracks.isNotEmpty) s += 20;
    if (tracks.length >= 2) s += 10;
    if (tracks.any((t) => t.skills.isNotEmpty)) s += 15;
    return s.clamp(0, 100);
  }

  // Next actionable tip.
  static String _nextTip(ProjectDraft d, List<TeamTrack> tracks) {
    if (d.title.trim().length < ProjectDraft.minTitleLength) {
      return 'Give your project a clear title (at least 3 characters).';
    }
    if (d.description.trim().length < ProjectDraft.minDescriptionLength) {
      return 'Add a description of at least 10 characters.';
    }
    if (d.description.trim().length < 40) {
      return 'Expand your description (40+ chars) to attract better matches.';
    }
    if (tracks.isEmpty) {
      return 'Next: add at least one needed track for your team.';
    }
    if (!tracks.any((t) => t.skills.isNotEmpty)) {
      return 'Select specific skills on your tracks for higher accuracy.';
    }
    return 'Looking great. Your project is ready to publish!';
  }

  // Launch readiness checklist.
  static List<ReadinessItem> _checklist(
    ProjectDraft d,
    List<TeamTrack> tracks,
  ) =>
      [
        ReadinessItem(
          'Project title & description',
          d.title.trim().length >= ProjectDraft.minTitleLength &&
              d.description.trim().length >= ProjectDraft.minDescriptionLength,
        ),
        ReadinessItem(
          'At least one open teammate track',
          tracks.any((t) => t.people > 0),
        ),
        ReadinessItem(
          'Skills specified for every track',
          tracks.isNotEmpty && tracks.every((t) => t.skills.isNotEmpty),
          required: false,
        ),
        ReadinessItem(
          'Expected end date set',
          d.expectedEndDate != null,
          required: false,
        ),
      ];

  // Derived tech stack list.
  static List<String> _techStack(ProjectDraft d, List<TeamTrack> tracks) {
    final out = <String>{
      for (final t in tracks)
        ...(t.skills.isNotEmpty ? t.skills : t.definition.skills.take(2)),
    };
    if (out.isEmpty) {
      out.addAll(TrackCatalog.byTrack(d.ownerTrack).skills.take(3));
    }
    return out.take(10).toList();
  }

  void _refresh() =>
      emit(_compute(_draftCubit.state.draft, _teamCubit.state.tracks));

  @override
  Future<void> close() {
    _draftSub.cancel();
    _teamSub.cancel();
    return super.close();
  }
}
