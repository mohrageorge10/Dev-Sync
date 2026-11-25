import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/project_firestore_mapper.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const registeredUser = DevBuilder(
    id: 'uid_3',
    name: 'Alex Chen',
    publicId: 'alexchen',
    track: UserTrack.mobile,
    level: UserLevel.intermediate,
    skills: ['Dart', 'Flutter'],
  );

  final draft = const ProjectDraft().copyWith(
    title: ' EcoTrack ',
    description: 'Carbon tracking app for communities',
    purpose: ProjectPurpose.real,
    difficulty: ProjectDifficulty.advanced,
    ownerTrack: UserTrack.backend,
    commitmentHoursPerWeek: 20,
    minLevel: UserLevel.junior,
    mentoring: true,
  );

  final tracks = [
    TeamTrack(
      definition: TrackCatalog.byTrack(UserTrack.mobile),
      people: 2,
      skills: {'Dart'},
      invites: [
        const Invite(registeredUser, message: 'Join our mobile track!'),
      ],
    ),
  ];

  const ownerSnapshot = <String, dynamic>{
    FirebaseConstants.fieldUid: 'owner_1',
    FirebaseConstants.fieldName: 'Project Owner',
    FirebaseConstants.fieldPublicId: 'owner_dev',
    FirebaseConstants.fieldPhotoUrl: '',
    FirebaseConstants.fieldTrack: 'backend',
    FirebaseConstants.fieldLevel: 'advanced',
  };

  Map<String, dynamic> build(ProjectStatus status) =>
      ProjectFirestoreMapper.projectData(
        draft: draft,
        tracks: tracks,
        status: status,
        ownerId: 'owner_1',
        ownerSnapshot: ownerSnapshot,
      );

  test('published project has the exact schema fields with owner filledCount = 1', () {
    final d = build(ProjectStatus.open);
    expect(d[FirebaseConstants.fieldTitle], 'EcoTrack');
    expect(d[FirebaseConstants.fieldDescription], 'Carbon tracking app for communities');
    expect(d[FirebaseConstants.fieldStatus], 'open');
    expect(d[FirebaseConstants.fieldOwnerId], 'owner_1');
    expect(d[FirebaseConstants.fieldOwnerTrack], 'backend');
    expect(d[FirebaseConstants.fieldPurpose], 'real');
    expect(d[FirebaseConstants.fieldDifficulty], 'advanced');
    expect(d[FirebaseConstants.fieldMinLevel], 'junior');
    expect(d[FirebaseConstants.fieldCommitmentHours], 20);
    expect(d[FirebaseConstants.fieldMentoring], isTrue);
    expect(d[FirebaseConstants.fieldTeamSize], 3); // 1 owner + 2 mobile
    expect(d[FirebaseConstants.fieldFilledCount], 1); // 1 owner filled
    expect(d[FirebaseConstants.fieldTrackKeys], ['mobile', 'backend']);
    expect(d[FirebaseConstants.fieldOpenTrackKeys], ['mobile']);

    final tracksMap = d[FirebaseConstants.fieldTracks] as Map;
    final mobileSlot = tracksMap['mobile'] as Map;
    expect(mobileSlot[FirebaseConstants.fieldSlotCount], 2);
    expect(mobileSlot[FirebaseConstants.fieldSlotFilled], 0);
    expect(mobileSlot[FirebaseConstants.fieldSlotSkills], ['Dart']);

    final backendSlot = tracksMap['backend'] as Map;
    expect(backendSlot[FirebaseConstants.fieldSlotCount], 1);
    expect(backendSlot[FirebaseConstants.fieldSlotFilled], 1);
  });

  test('draft keeps registered invites in draftInvites, published clears draftInvites', () {
    final asDraft = build(ProjectStatus.draft);
    final live = build(ProjectStatus.open);
    expect((asDraft[FirebaseConstants.fieldDraftInvites] as List).length, 1);
    expect((live[FirebaseConstants.fieldDraftInvites] as List), isEmpty);
  });

  test('invitations include full ownerSnapshot, inviteeSnapshot, and composite docId', () {
    final list = ProjectFirestoreMapper.invitations(
      projectId: 'p1',
      draft: draft,
      tracks: tracks,
      ownerId: 'owner_1',
      ownerSnapshot: ownerSnapshot,
    );
    expect(list.length, 1);
    expect(list.first.docId, 'p1_uid_3');
    expect(list.first.inviteeId, 'uid_3');
    expect(list.first.data[FirebaseConstants.fieldStatus], 'pending');
    expect(list.first.data[FirebaseConstants.fieldTrack], 'mobile');
    expect(list.first.data[FirebaseConstants.fieldMessage], 'Join our mobile track!');
    expect(list.first.data[FirebaseConstants.fieldOwnerSnapshot], ownerSnapshot);
    expect(
      (list.first.data[FirebaseConstants.fieldInviteeSnapshot] as Map)[FirebaseConstants.fieldPublicId],
      'alexchen',
    );
  });

  test('teamData and ownerMemberData initialize teams and members documents', () {
    final team = ProjectFirestoreMapper.teamData(
      projectId: 'p1',
      draft: draft,
      ownerId: 'owner_1',
    );
    expect(team[FirebaseConstants.fieldProjectId], 'p1');
    expect(team[FirebaseConstants.fieldMemberIds], ['owner_1']);

    final member = ProjectFirestoreMapper.ownerMemberData(
      draft: draft,
      ownerId: 'owner_1',
      ownerSnapshot: ownerSnapshot,
    );
    expect(member[FirebaseConstants.fieldUid], 'owner_1');
    expect(member[FirebaseConstants.fieldTrack], 'backend');
    expect(member[FirebaseConstants.fieldIsOwner], isTrue);
  });
}
