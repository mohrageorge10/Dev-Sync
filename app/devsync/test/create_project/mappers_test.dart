import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every track id is a UserTrack name (and the other way round)', () {
    expect(
      TrackCatalog.all.map((t) => t.id).toSet(),
      UserTrack.values.map((t) => t.name).toSet(),
    );
  });

  test('ProjectPurpose and ProjectDifficulty have display labels', () {
    expect(ProjectPurpose.learning.label, 'Learning');
    expect(ProjectPurpose.real.label, 'Real-world');
    expect(ProjectDifficulty.beginner.label, 'Beginner');
    expect(ProjectDifficulty.junior.label, 'Junior');
    expect(ProjectDifficulty.intermediate.label, 'Intermediate');
    expect(ProjectDifficulty.advanced.label, 'Advanced');
  });

  test('draft validity and what is missing', () {
    const empty = ProjectDraft();
    expect(empty.isValid, isFalse);
    expect(empty.missing, ['title', 'description']);

    final ok = empty.copyWith(
      title: 'EcoTrack',
      description: 'Carbon footprint tracker application',
    );
    expect(ok.isValid, isTrue);
    expect(ok.missing, isEmpty);
  });

  test('expected end date can be cleared', () {
    final withDate = const ProjectDraft().copyWith(
      expectedEndDate: DateTime(2027, 1, 1),
    );
    expect(withDate.expectedEndDate, isNotNull);
    expect(
      withDate.copyWith(clearExpectedEndDate: true).expectedEndDate,
      isNull,
    );
  });

  test('DevBuilder initials and snapshot never crash', () {
    const none = DevBuilder(
      id: '1',
      name: '',
      publicId: 'h',
      track: UserTrack.ai,
      skills: [],
    );
    const one = DevBuilder(
      id: '2',
      name: 'sara',
      publicId: 'h',
      track: UserTrack.ai,
      skills: [],
    );
    const two = DevBuilder(
      id: '3',
      name: 'Sarah  Lin',
      publicId: 'sarahlin',
      track: UserTrack.ai,
      skills: [],
    );
    expect(none.initials, '?');
    expect(one.initials, 'S');
    expect(two.initials, 'SL');
    expect(two.toSnapshot()['publicId'], 'sarahlin');
  });
}
