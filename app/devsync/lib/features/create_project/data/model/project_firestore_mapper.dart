import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:devsync/features/create_project/data/model/track_catalog.dart';
import 'package:equatable/equatable.dart';

// Firestore invitation payload.
class ProjectInvitation extends Equatable {
  const ProjectInvitation({
    required this.docId,
    required this.inviteeId,
    required this.data,
  });

  final String docId;
  final String inviteeId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [docId, inviteeId, data];
}

// Maps draft and team state to Firestore documents.
class ProjectFirestoreMapper {
  const ProjectFirestoreMapper._();

  // Build project document data.
  static Map<String, dynamic> projectData({
    required ProjectDraft draft,
    required List<TeamTrack> tracks,
    required ProjectStatus status,
    required String ownerId,
    required Map<String, dynamic> ownerSnapshot,
  }) {
    final ownerKey = draft.ownerTrack.name;
    final openKeys =
        tracks.where((t) => t.people > 0).map((t) => t.definition.id).toList();
    final trackMap = <String, dynamic>{};

    for (final t in tracks) {
      final isOwner = t.definition.id == ownerKey;
      trackMap[t.definition.id] = {
        FirebaseConstants.fieldSlotCount: t.people + (isOwner ? 1 : 0),
        FirebaseConstants.fieldSlotFilled: isOwner ? 1 : 0,
        FirebaseConstants.fieldSlotSkills: [...t.skills]..sort(),
      };
    }

    trackMap.putIfAbsent(ownerKey, () => {
          FirebaseConstants.fieldSlotCount: 1,
          FirebaseConstants.fieldSlotFilled: 1,
          FirebaseConstants.fieldSlotSkills: <String>[],
        });

    final techStack = <String>{
      for (final t in tracks)
        ...(t.skills.isNotEmpty ? t.skills : t.definition.skills.take(2)),
    };
    if (techStack.isEmpty) {
      techStack.addAll(TrackCatalog.byTrack(draft.ownerTrack).skills.take(2));
    }

    return {
      FirebaseConstants.fieldTitle: draft.title.trim(),
      FirebaseConstants.fieldDescription: draft.description.trim(),
      FirebaseConstants.fieldStatus: status.name,
      FirebaseConstants.fieldOwnerId: ownerId,
      FirebaseConstants.fieldOwnerSnapshot: ownerSnapshot,
      FirebaseConstants.fieldOwnerTrack: ownerKey,
      FirebaseConstants.fieldPurpose: draft.purpose.name,
      FirebaseConstants.fieldDifficulty: draft.difficulty.name,
      FirebaseConstants.fieldMinLevel: draft.minLevel.name,
      FirebaseConstants.fieldCommitmentHours: draft.commitmentHoursPerWeek,
      FirebaseConstants.fieldExpectedEndDate:
          draft.expectedEndDate?.toIso8601String(),
      FirebaseConstants.fieldMentoring: draft.mentoring,
      FirebaseConstants.fieldTeamSize:
          1 + tracks.fold<int>(0, (s, t) => s + t.people),
      FirebaseConstants.fieldFilledCount: 1,
      FirebaseConstants.fieldTechStack: techStack.toList(),
      FirebaseConstants.fieldTrackKeys: trackMap.keys.toList(),
      FirebaseConstants.fieldOpenTrackKeys: openKeys,
      FirebaseConstants.fieldTracks: trackMap,
      FirebaseConstants.fieldDraftInvites: _draftInvites(tracks, status),
      'repoUrl': draft.repoUrl.trim(),
      'cloneUrl': draft.effectiveCloneUrl,
      'defaultBranch': draft.defaultBranch.trim().isEmpty
          ? 'develop'
          : draft.defaultBranch.trim(),
      'gitRules': draft.gitRulesMap,
    };
  }

  // Build teams/{projectId} document.
  static Map<String, dynamic> teamData({
    required String projectId,
    required ProjectDraft draft,
    required String ownerId,
  }) => {
    FirebaseConstants.fieldProjectId: projectId,
    FirebaseConstants.fieldProjectTitle: draft.title.trim(),
    FirebaseConstants.fieldOwnerId: ownerId,
    FirebaseConstants.fieldMemberIds: <String>[ownerId],
    FirebaseConstants.fieldExpectedEndDate:
        draft.expectedEndDate?.toIso8601String(),
    'repoUrl': draft.repoUrl.trim(),
    'defaultBranch': draft.defaultBranch.trim().isEmpty
        ? 'develop'
        : draft.defaultBranch.trim(),
  };

  // Build teams/{projectId}/members/{ownerId} document.
  static Map<String, dynamic> ownerMemberData({
    required ProjectDraft draft,
    required String ownerId,
    required Map<String, dynamic> ownerSnapshot,
  }) =>
      {
        FirebaseConstants.fieldUid: ownerId,
        FirebaseConstants.fieldName:
            ownerSnapshot[FirebaseConstants.fieldName] ?? 'Project Owner',
        FirebaseConstants.fieldPhotoUrl:
            ownerSnapshot[FirebaseConstants.fieldPhotoUrl] ?? '',
        FirebaseConstants.fieldPublicId:
            ownerSnapshot[FirebaseConstants.fieldPublicId] ?? ownerId,
        FirebaseConstants.fieldTrack: draft.ownerTrack.name,
        FirebaseConstants.fieldLevel:
            ownerSnapshot[FirebaseConstants.fieldLevel] ?? draft.minLevel.name,
        FirebaseConstants.fieldIsOwner: true,
        FirebaseConstants.fieldJoinedVia: 'owner',
      };

  // Build invitations/{projectId}_{inviteeId} documents.
  static List<ProjectInvitation> invitations({
    required String projectId,
    required ProjectDraft draft,
    required List<TeamTrack> tracks,
    required String ownerId,
    required Map<String, dynamic> ownerSnapshot,
  }) =>
      [
        for (final t in tracks)
          for (final inv in t.invites)
            ProjectInvitation(
              docId: FirebaseConstants.invitationDocId(projectId, inv.builder.id),
              inviteeId: inv.builder.id,
              data: {
                FirebaseConstants.fieldProjectId: projectId,
                FirebaseConstants.fieldProjectTitle: draft.title.trim(),
                FirebaseConstants.fieldOwnerId: ownerId,
                FirebaseConstants.fieldOwnerSnapshot: ownerSnapshot,
                FirebaseConstants.fieldInviteeId: inv.builder.id,
                FirebaseConstants.fieldInviteeSnapshot: inv.builder.toSnapshot(),
                FirebaseConstants.fieldTrack: t.definition.id,
                FirebaseConstants.fieldMessage: inv.message,
                FirebaseConstants.fieldStatus: InvitationStatus.pending.name,
              },
            ),
      ];

  // Draft invites stored only while status is draft.
  static List<Map<String, dynamic>> _draftInvites(
    List<TeamTrack> tracks,
    ProjectStatus status,
  ) =>
      status != ProjectStatus.draft
          ? const []
          : [
              for (final t in tracks)
                for (final inv in t.invites)
                  {
                    FirebaseConstants.fieldTrack: t.definition.id,
                    FirebaseConstants.fieldInviteeId: inv.builder.id,
                    FirebaseConstants.fieldInviteeSnapshot:
                        inv.builder.toSnapshot(),
                    if (inv.message.isNotEmpty)
                      FirebaseConstants.fieldMessage: inv.message,
                  },
            ];
}
