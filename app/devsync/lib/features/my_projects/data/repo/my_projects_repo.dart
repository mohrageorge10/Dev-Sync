import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart'
    as discover;

import '../models/applicant_model.dart';
import '../models/developer_model.dart';
import '../models/invitation_model.dart';
import '../models/my_application_model.dart';
import '../models/project_model.dart';

// Firestore-backed repository for My Projects with local showcase fallback.
class MyProjectsRepo {
  MyProjectsRepo({
    FirestoreService? firestoreService,
    FirebaseAuthService? authService,
  }) : _firestore = firestoreService,
       _auth = authService;

  final FirestoreService? _firestore;
  final FirebaseAuthService? _auth;

  // Fetch both owned projects and projects joined via teams/{teamId}.
  Future<List<ProjectModel>> getProjects() async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid != null && fs != null) {
      try {
        final byId = <String, ProjectModel>{};

        final ownedDocs = await fs.getCollection(
          collectionPath: FirebaseConstants.projectsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
        );
        for (final doc in ownedDocs) {
          final p = _projectFromDoc(doc, uid);
          if (p.id.isNotEmpty) byId[p.id] = p;
        }

        final teamDocs = await fs.getCollection(
          collectionPath: FirebaseConstants.teamsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldMemberIds, arrayContains: uid),
        );
        for (final tDoc in teamDocs) {
          final pid =
              (tDoc[FirebaseConstants.fieldProjectId] ?? tDoc['id'] ?? '')
                  .toString();
          if (pid.isEmpty || byId.containsKey(pid)) continue;
          final pDoc = await fs.getDocument(
            collectionPath: FirebaseConstants.projectsCollection,
            docId: pid,
          );
          if (pDoc != null) {
            byId[pid] = _projectFromDoc({...pDoc, 'id': pid}, uid);
          }
        }

        // Also include projects where this user's join request was accepted.
        final acceptedReqs = await fs.getCollection(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) => q
              .where(FirebaseConstants.fieldApplicantId, isEqualTo: uid)
              .where(FirebaseConstants.fieldStatus, isEqualTo: 'accepted'),
        );
        for (final req in acceptedReqs) {
          final pid = (req[FirebaseConstants.fieldProjectId] ?? '').toString();
          if (pid.isEmpty || byId.containsKey(pid)) continue;
          final pDoc = await fs.getDocument(
            collectionPath: FirebaseConstants.projectsCollection,
            docId: pid,
          );
          if (pDoc != null) {
            byId[pid] = _projectFromDoc({...pDoc, 'id': pid}, uid);
            // Ensure user is listed in teams/{pid}.memberIds and teams/{pid}/members/{uid}.
            final userDoc = await fs.getDocument(
              collectionPath: FirebaseConstants.usersCollection,
              docId: uid,
            );
            final name =
                (userDoc?[FirebaseConstants.fieldName] ??
                        _auth?.currentUser?.displayName ??
                        'Developer')
                    .toString();
            final handle =
                (userDoc?[FirebaseConstants.fieldPublicId] ??
                        name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''))
                    .toString();
            final track =
                (req[FirebaseConstants.fieldTrack] ??
                        userDoc?[FirebaseConstants.fieldTrack] ??
                        'Member')
                    .toString();
            await fs.setDocument(
              collectionPath:
                  '${FirebaseConstants.teamsCollection}/$pid/${FirebaseConstants.membersCollection}',
              docId: uid,
              data: {
                FirebaseConstants.fieldUid: uid,
                FirebaseConstants.fieldName: name,
                'username': handle,
                FirebaseConstants.fieldTrack: track,
                'teamRole': 'member',
                FirebaseConstants.fieldIsOwner: false,
                FirebaseConstants.fieldJoinedAt: fs.serverTimestamp,
              },
              merge: true,
            );
            await fs.setDocument(
              collectionPath: FirebaseConstants.teamsCollection,
              docId: pid,
              data: {
                FirebaseConstants.fieldProjectId: pid,
                FirebaseConstants.fieldMemberIds: FieldValue.arrayUnion([uid]),
              },
              merge: true,
            );
          }
        }

        return byId.values.toList();
      } catch (_) {}
    }
    return const [];
  }

  // Fetch incoming project invitations for the current user (ignoring deleted projects).
  Future<List<InvitationModel>> getInvitations() async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid != null && fs != null) {
      try {
        final docs = await fs.getCollection(
          collectionPath: FirebaseConstants.invitationsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldInviteeId, isEqualTo: uid),
        );
        final valid = <InvitationModel>[];
        for (final d in docs) {
          final inv = _invitationFromDoc(d);
          if (await _projectExists(fs, inv.projectId)) valid.add(inv);
        }
        return valid;
      } catch (_) {}
    }
    return const [];
  }

  // Fetch incoming join requests across the user's owned projects (real Firestore data only).
  Future<List<ApplicantModel>> getApplicants({
    List<String> ownedProjectIds = const [],
  }) async {
    final fs = _firestore;
    final uid = _auth?.currentUserId;
    if (fs != null && uid != null) {
      try {
        final docs = await fs.getCollection(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
        );
        return docs.map(_applicantFromDoc).toList();
      } catch (_) {}
    }
    return const [];
  }

  // Fetch outgoing join requests submitted by the current user (ignoring deleted projects).
  Future<List<MyApplicationModel>> getMyApplications() async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid != null && fs != null) {
      try {
        final docs = await fs.getCollection(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldApplicantId, isEqualTo: uid),
        );
        final valid = <MyApplicationModel>[];
        for (final d in docs) {
          final app = _myApplicationFromDoc(d);
          if (await _projectExists(fs, app.projectId)) valid.add(app);
        }
        return valid;
      } catch (_) {}
    }
    return const [];
  }

  // Real-time stream of outgoing join requests submitted by the current user (ignoring deleted projects).
  Stream<List<MyApplicationModel>> watchMyApplications() {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return const Stream.empty();
    return fs
        .collectionStream(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldApplicantId, isEqualTo: uid),
        )
        .asyncMap((docs) async {
          final valid = <MyApplicationModel>[];
          for (final d in docs) {
            final app = _myApplicationFromDoc(d);
            if (await _projectExists(fs, app.projectId)) valid.add(app);
          }
          return valid;
        });
  }

  // Check whether a referenced project document still exists in Firestore.
  Future<bool> _projectExists(FirestoreService fs, String projectId) async {
    if (projectId.isEmpty) return false;
    final doc = await fs.getDocument(
      collectionPath: FirebaseConstants.projectsCollection,
      docId: projectId,
    );
    return doc != null;
  }

  // Withdraw a pending outgoing application.
  Future<void> withdrawApplication(String requestId) async {
    final fs = _firestore;
    if (fs == null || requestId.isEmpty) return;
    try {
      await fs.deleteDocument(
        collectionPath: FirebaseConstants.requestsCollection,
        docId: requestId,
      );
    } catch (_) {}
  }

  // Fetch recommended developers to invite (real Firestore data only).
  Future<List<DeveloperModel>> getDevelopers() async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (fs != null) {
      try {
        final docs = await fs.getCollection(
          collectionPath: FirebaseConstants.usersCollection,
        );
        return docs
            .where((d) => (d['id'] ?? d[FirebaseConstants.fieldUid]) != uid)
            .take(15)
            .map(_developerFromDoc)
            .toList();
      } catch (_) {}
    }
    return const [];
  }

  // Real-time stream of projects owned by the current user.
  Stream<List<ProjectModel>> watchOwnedProjects() {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return const Stream.empty();
    return fs
        .collectionStream(
          collectionPath: FirebaseConstants.projectsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
        )
        .map((docs) => docs.map((d) => _projectFromDoc(d, uid)).toList());
  }

  // Real-time stream of projects joined by the current user via teams/{projectId}.
  Stream<List<ProjectModel>> watchJoinedProjects() {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return const Stream.empty();
    return fs
        .collectionStream(
          collectionPath: FirebaseConstants.teamsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldMemberIds, arrayContains: uid),
        )
        .asyncMap((teamDocs) async {
          final joined = <ProjectModel>[];
          for (final tDoc in teamDocs) {
            final pid =
                (tDoc[FirebaseConstants.fieldProjectId] ?? tDoc['id'] ?? '')
                    .toString();
            if (pid.isEmpty) continue;
            final pDoc = await fs.getDocument(
              collectionPath: FirebaseConstants.projectsCollection,
              docId: pid,
            );
            if (pDoc != null) {
              final model = _projectFromDoc({...pDoc, 'id': pid}, uid);
              if (!model.isOwner) joined.add(model);
            }
          }
          return joined;
        });
  }

  // Real-time stream of incoming project invitations (ignoring deleted projects).
  Stream<List<InvitationModel>> watchInvitations() {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return const Stream.empty();
    return fs
        .collectionStream(
          collectionPath: FirebaseConstants.invitationsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldInviteeId, isEqualTo: uid),
        )
        .asyncMap((docs) async {
          final valid = <InvitationModel>[];
          for (final d in docs) {
            final inv = _invitationFromDoc(d);
            if (inv.projectId.isNotEmpty) {
              final exists = await fs.getDocument(
                collectionPath: FirebaseConstants.projectsCollection,
                docId: inv.projectId,
              );
              if (exists == null) continue;
            }
            valid.add(inv);
          }
          return valid;
        });
  }

  // Real-time stream of incoming join requests for projects owned by the current user.
  Stream<List<ApplicantModel>> watchIncomingApplicants() {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return const Stream.empty();
    return fs
        .collectionStream(
          collectionPath: FirebaseConstants.requestsCollection,
          queryBuilder: (q) =>
              q.where(FirebaseConstants.fieldOwnerId, isEqualTo: uid),
        )
        .map((docs) => docs.map(_applicantFromDoc).toList());
  }

  // Resolve full developer profile for an applicant (Firestore first, local fallback).
  Future<discover.DeveloperModel> resolveApplicantProfile(
    ApplicantModel applicant,
  ) async {
    final fs = _firestore;
    if (fs != null && applicant.applicantUid.isNotEmpty) {
      try {
        final doc = await fs.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: applicant.applicantUid,
        );
        if (doc != null) {
          return discover.DeveloperModel.fromFirestore({
            ...doc,
            'id': applicant.applicantUid,
          });
        }
      } catch (_) {}
    }
    final cleanHandle = applicant.username.isNotEmpty
        ? applicant.username.replaceAll('@', '')
        : applicant.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return discover.DeveloperModel(
      id: applicant.applicantUid.isNotEmpty
          ? applicant.applicantUid
          : applicant.id,
      name: applicant.name,
      publicId: '@$cleanHandle',
      imageUrl: applicant.photoUrl,
      hasGithub: true,
      role: applicant.title,
      level: applicant.level,
      skills: applicant.skills.isEmpty
          ? const ['Flutter', 'Dart']
          : applicant.skills,
      bio: applicant.coverNote,
      matchPercent: applicant.matchPercent,
      githubUrl: 'https://github.com/$cleanHandle',
    );
  }

  // Persist edited project details to projects/{projectId} and sync teams/{projectId}.
  Future<void> updateProjectDetails(ProjectModel project) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldTitle: project.name,
          FirebaseConstants.fieldDescription: project.description,
          FirebaseConstants.fieldTeamSize: project.totalSeats,
          FirebaseConstants.fieldTechStack: project.tags,
          FirebaseConstants.fieldOpenTrackKeys: project.openRoles,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
      await fs.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldProjectTitle: project.name,
          FirebaseConstants.fieldTeamSize: project.totalSeats,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Persist repository link, clone URL, default branch, and Git rules, and sync teams/{projectId}.
  Future<void> updateRepoAndRules(ProjectModel project) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: project.id,
        data: {
          'repoUrl': project.repoUrl,
          'cloneUrl': project.cloneUrl,
          'defaultBranch': project.defaultBranch,
          'gitRules': project.gitRules.toMap(),
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
      await fs.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: project.id,
        data: {
          'repoUrl': project.repoUrl,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Persist invitation response and add current user to teams/{projectId} when accepted.
  Future<void> respondToInvitation(
    InvitationModel invitation,
    bool accept,
  ) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.invitationsCollection,
        docId: invitation.id,
        data: {
          FirebaseConstants.fieldStatus: accept ? 'accepted' : 'declined',
          FirebaseConstants.fieldRespondedAt: fs.serverTimestamp,
        },
      );
      final uid = _auth?.currentUserId;
      if (accept && uid != null && invitation.projectId.isNotEmpty) {
        final userDoc = await fs.getDocument(
          collectionPath: FirebaseConstants.usersCollection,
          docId: uid,
        );
        final name =
            (userDoc?[FirebaseConstants.fieldName] ??
                    _auth?.currentUser?.displayName ??
                    'Developer')
                .toString();
        final username =
            (userDoc?[FirebaseConstants.fieldPublicId] ??
                    name.toLowerCase().replaceAll(' ', ''))
                .toString();
        await fs.setDocument(
          collectionPath:
              '${FirebaseConstants.teamsCollection}/${invitation.projectId}/${FirebaseConstants.membersCollection}',
          docId: uid,
          data: {
            FirebaseConstants.fieldUid: uid,
            FirebaseConstants.fieldName: name,
            'username': username,
            FirebaseConstants.fieldTrack: invitation.role,
            'teamRole': 'member',
            FirebaseConstants.fieldIsOwner: false,
            FirebaseConstants.fieldJoinedAt: fs.serverTimestamp,
          },
          merge: true,
        );
        await fs.setDocument(
          collectionPath: FirebaseConstants.teamsCollection,
          docId: invitation.projectId,
          data: {
            FirebaseConstants.fieldMemberIds: FieldValue.arrayUnion([uid]),
            FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
          },
          merge: true,
        );
        await fs.setDocument(
          collectionPath: FirebaseConstants.projectsCollection,
          docId: invitation.projectId,
          data: {
            FirebaseConstants.fieldFilledCount: FieldValue.increment(1),
            FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
          },
          merge: true,
        );
      }
    } catch (_) {}
  }

  // Persist applicant decision, update filledCount & openTrackKeys, and add member to teams/{projectId}.
  Future<void> respondToApplicant(
    ApplicantModel applicant,
    bool accept, {
    int? updatedMembersCount,
    List<String>? updatedOpenRoles,
  }) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.requestsCollection,
        docId: applicant.id,
        data: {
          FirebaseConstants.fieldStatus: accept ? 'accepted' : 'declined',
          FirebaseConstants.fieldDecidedAt: fs.serverTimestamp,
        },
      );
      if (accept && applicant.projectId.isNotEmpty) {
        if (updatedMembersCount != null || updatedOpenRoles != null) {
          try {
            await fs.updateDocument(
              collectionPath: FirebaseConstants.projectsCollection,
              docId: applicant.projectId,
              data: {
                FirebaseConstants.fieldFilledCount: ?updatedMembersCount,
                FirebaseConstants.fieldOpenTrackKeys: ?updatedOpenRoles,
                FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
              },
            );
          } catch (_) {}
        }
        final memberUid = applicant.applicantUid.isNotEmpty
            ? applicant.applicantUid
            : applicant.id;
        final handle = applicant.username.isNotEmpty
            ? applicant.username
            : applicant.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        try {
          await fs.setDocument(
            collectionPath:
                '${FirebaseConstants.teamsCollection}/${applicant.projectId}/${FirebaseConstants.membersCollection}',
            docId: memberUid,
            data: {
              FirebaseConstants.fieldUid: memberUid,
              FirebaseConstants.fieldName: applicant.name,
              'username': handle,
              FirebaseConstants.fieldTrack: applicant.position,
              'teamRole': 'member',
              FirebaseConstants.fieldIsOwner: false,
              FirebaseConstants.fieldJoinedAt: fs.serverTimestamp,
            },
            merge: true,
          );
        } catch (_) {}
        try {
          await fs.setDocument(
            collectionPath: FirebaseConstants.teamsCollection,
            docId: applicant.projectId,
            data: {
              FirebaseConstants.fieldMemberIds: FieldValue.arrayUnion([
                memberUid,
              ]),
              FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
            },
            merge: true,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  // Send a project invitation to a developer in Firestore.
  Future<void> sendInvitation({
    required ProjectModel project,
    required DeveloperModel developer,
    required String role,
    required String message,
  }) async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (uid == null || fs == null) return;
    try {
      await fs.setDocument(
        collectionPath: FirebaseConstants.invitationsCollection,
        docId: FirebaseConstants.invitationDocId(project.id, developer.id),
        data: {
          FirebaseConstants.fieldProjectId: project.id,
          FirebaseConstants.fieldProjectTitle: project.name,
          FirebaseConstants.fieldOwnerId: uid,
          FirebaseConstants.fieldInviteeId: developer.id,
          FirebaseConstants.fieldTrack: role,
          FirebaseConstants.fieldMessage: message,
          FirebaseConstants.fieldStatus: 'pending',
          FirebaseConstants.fieldCreatedAt: fs.serverTimestamp,
        },
      );
    } catch (_) {}
  }

  // Publish a saved draft project (draft -> open) and initialize its teams/{projectId} workspace.
  Future<void> publishDraft(ProjectModel project) async {
    final fs = _firestore;
    final uid = _auth?.currentUserId;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldStatus: 'open',
          FirebaseConstants.fieldPublishedAt: fs.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
      );
      if (uid != null) {
        await ensureTeamWorkspace(project);
      }
    } catch (_) {}
  }

  // Ensure teams/{project.id} and owner member doc exist in Firestore.
  Future<void> ensureTeamWorkspace(ProjectModel project) async {
    final fs = _firestore;
    final uid = _auth?.currentUserId;
    if (fs == null || uid == null || project.id.isEmpty) return;
    try {
      final existingTeam = await fs.getDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: project.id,
      );
      if (existingTeam != null) return;

      final userDoc = await fs.getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      final name =
          (userDoc?[FirebaseConstants.fieldName] ??
                  _auth?.currentUser?.displayName ??
                  'Project Owner')
              .toString();
      final username =
          (userDoc?['username'] ??
                  userDoc?[FirebaseConstants.fieldPublicId] ??
                  name.toLowerCase().replaceAll(' ', ''))
              .toString();
      final track = (userDoc?[FirebaseConstants.fieldTrack] ?? 'Project Lead')
          .toString();

      await fs.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldProjectId: project.id,
          FirebaseConstants.fieldProjectTitle: project.name,
          FirebaseConstants.fieldOwnerId: uid,
          FirebaseConstants.fieldMemberIds: [uid],
          FirebaseConstants.fieldTeamSize: project.totalSeats,
          FirebaseConstants.fieldOpenTrackKeys: project.openRoles,
          'repoUrl': project.repoUrl,
          'sprint': 'Sprint 1',
          'version': 'v1.0.0',
          FirebaseConstants.fieldCreatedAt: fs.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
      await fs.setDocument(
        collectionPath:
            '${FirebaseConstants.teamsCollection}/${project.id}/${FirebaseConstants.membersCollection}',
        docId: uid,
        data: {
          FirebaseConstants.fieldUid: uid,
          FirebaseConstants.fieldName: name,
          'username': username,
          FirebaseConstants.fieldTrack: track,
          'teamRole': 'owner',
          FirebaseConstants.fieldIsOwner: true,
          FirebaseConstants.fieldJoinedAt: fs.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Delete a project and clean up its orphan invitations and join requests.
  Future<void> deleteProject(String projectId) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.deleteDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: projectId,
      );
      final invDocs = await fs.getCollection(
        collectionPath: FirebaseConstants.invitationsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldProjectId, isEqualTo: projectId),
      );
      for (final d in invDocs) {
        final id = (d['id'] ?? '').toString();
        if (id.isNotEmpty) {
          await fs.deleteDocument(
            collectionPath: FirebaseConstants.invitationsCollection,
            docId: id,
          );
        }
      }
      final reqDocs = await fs.getCollection(
        collectionPath: FirebaseConstants.requestsCollection,
        queryBuilder: (q) =>
            q.where(FirebaseConstants.fieldProjectId, isEqualTo: projectId),
      );
      for (final d in reqDocs) {
        final id = (d['id'] ?? '').toString();
        if (id.isNotEmpty) {
          await fs.deleteDocument(
            collectionPath: FirebaseConstants.requestsCollection,
            docId: id,
          );
        }
      }
    } catch (_) {}
  }

  // Update project lifecycle status (archived or open) and notify teams/{projectId} listeners.
  Future<void> setProjectArchived(String projectId, bool archived) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: projectId,
        data: {
          FirebaseConstants.fieldStatus: archived ? 'archived' : 'open',
          if (archived) 'outcome': ProjectOutcome.archived.firestoreValue,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
      );
      await fs.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: projectId,
        data: {
          FirebaseConstants.fieldStatus: archived ? 'archived' : 'open',
          'subtitle': archived ? 'Archived' : 'Active • Real-world',
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  // Complete or ship a project and sync teams/{projectId} so all members update in real time.
  Future<void> completeProject(ProjectModel project) async {
    final fs = _firestore;
    if (fs == null) return;
    final outcome = project.outcome ?? ProjectOutcome.completed;
    try {
      await fs.setDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldStatus: outcome.firestoreValue,
          'outcome': outcome.firestoreValue,
          'productLogoUrl': project.productLogoUrl.trim(),
          'productUrl': project.productUrl.trim(),
          'awards': project.awards,
          'completionSummary': project.completionSummary.trim(),
          'completedAt': project.completedAt != null
              ? Timestamp.fromDate(project.completedAt!)
              : fs.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
      await fs.setDocument(
        collectionPath: FirebaseConstants.teamsCollection,
        docId: project.id,
        data: {
          FirebaseConstants.fieldStatus: outcome.firestoreValue,
          'subtitle': outcome.label,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
        merge: true,
      );
    } catch (_) {}
  }

  ProjectModel _projectFromDoc(Map<String, dynamic> d, String uid) {
    final status = (d[FirebaseConstants.fieldStatus] ?? 'open')
        .toString()
        .toLowerCase();
    final isDraft = status == 'draft';
    final isPrevious =
        status == 'archived' || status == 'completed' || status == 'shipped';
    final outcome =
        ProjectOutcome.fromString(d['outcome']?.toString()) ??
        (isPrevious ? ProjectOutcome.fromString(status) : null);
    final rawTags = d[FirebaseConstants.fieldTechStack];
    final rawOpen = d[FirebaseConstants.fieldOpenTrackKeys];
    final rawAwards = d['awards'];
    final repoUrl = (d['repoUrl'] ?? '').toString();
    final cloneUrl = (d['cloneUrl'] ?? ProjectModel.deriveCloneUrl(repoUrl))
        .toString();
    final rawRules = d['gitRules'];
    final id = (d['id'] ?? '').toString();
    final rawCode = (d['projectCode'] ?? '').toString().trim();
    final projectCode = rawCode.isNotEmpty
        ? rawCode
        : (id.length >= 5
              ? 'PRJ-${id.substring(0, 5).toUpperCase()}'
              : 'PRJ-$id');

    DateTime? completedAt;
    final rawCompleted = d['completedAt'];
    if (rawCompleted is Timestamp) {
      completedAt = rawCompleted.toDate();
    } else if (rawCompleted is String) {
      completedAt = DateTime.tryParse(rawCompleted);
    }

    String period = '';
    if (completedAt != null) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      period =
          'Completed ${months[completedAt.month - 1]} ${completedAt.day}, ${completedAt.year}';
    }

    return ProjectModel(
      id: id,
      projectCode: projectCode,
      name: (d[FirebaseConstants.fieldTitle] ?? 'Untitled Project').toString(),
      description: (d[FirebaseConstants.fieldDescription] ?? '').toString(),
      statusText: isDraft
          ? 'Draft'
          : isPrevious
          ? (outcome?.label ?? 'Completed')
          : 'Active • Open',
      isOwner: d[FirebaseConstants.fieldOwnerId]?.toString() == uid,
      membersCount: (d[FirebaseConstants.fieldFilledCount] is num)
          ? (d[FirebaseConstants.fieldFilledCount] as num).toInt()
          : 1,
      totalSeats: (d[FirebaseConstants.fieldTeamSize] is num)
          ? (d[FirebaseConstants.fieldTeamSize] as num).toInt()
          : 4,
      tags: rawTags is Iterable
          ? rawTags.map((e) => e.toString()).toList()
          : const [],
      openRoles: rawOpen is Iterable
          ? rawOpen.map((e) => e.toString()).toList()
          : const [],
      period: period,
      type: isDraft
          ? ProjectType.draft
          : isPrevious
          ? ProjectType.previous
          : ProjectType.ongoing,
      repoUrl: repoUrl,
      cloneUrl: cloneUrl,
      defaultBranch: (d['defaultBranch'] ?? 'develop').toString(),
      gitRules: GitWorkflowRules.fromMap(
        rawRules is Map ? Map<String, dynamic>.from(rawRules) : null,
      ),
      outcome: outcome,
      productLogoUrl: (d['productLogoUrl'] ?? '').toString(),
      productUrl: (d['productUrl'] ?? '').toString(),
      awards: rawAwards is Iterable
          ? rawAwards
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
      completionSummary: (d['completionSummary'] ?? '').toString(),
      completedAt: completedAt,
    );
  }

  InvitationModel _invitationFromDoc(Map<String, dynamic> d) {
    final rawStatus = (d[FirebaseConstants.fieldStatus] ?? 'pending')
        .toString()
        .toLowerCase();
    final status = switch (rawStatus) {
      'accepted' => InvitationStatus.accepted,
      'declined' => InvitationStatus.declined,
      _ => InvitationStatus.pending,
    };
    return InvitationModel(
      id: (d['id'] ?? '').toString(),
      projectId: (d[FirebaseConstants.fieldProjectId] ?? '').toString(),
      projectName:
          (d[FirebaseConstants.fieldProjectTitle] ?? 'Project Invitation')
              .toString(),
      ownerName: (d['ownerName'] ?? 'Project Owner').toString(),
      ownerRole: 'Project Lead',
      note:
          (d[FirebaseConstants.fieldMessage] ??
                  'You have been invited to join our team.')
              .toString(),
      role: (d[FirebaseConstants.fieldTrack] ?? 'Contributor').toString(),
      hoursPerWeek: '6-8 hrs / wk',
      level: 'Intermediate',
      responsibilities: const ['Collaborate on sprint milestones'],
      skills: const ['Flutter', 'Dart'],
      status: status,
    );
  }

  MyApplicationModel _myApplicationFromDoc(Map<String, dynamic> d) {
    final rawStatus = (d[FirebaseConstants.fieldStatus] ?? 'pending')
        .toString()
        .toLowerCase();
    final status = switch (rawStatus) {
      'accepted' => ApplicationStatus.accepted,
      'declined' || 'rejected' => ApplicationStatus.declined,
      _ => ApplicationStatus.pending,
    };
    final rawCreated = d[FirebaseConstants.fieldCreatedAt];
    DateTime? createdAt;
    if (rawCreated is Timestamp) {
      createdAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated);
    }
    return MyApplicationModel(
      id: (d['id'] ?? '').toString(),
      projectId: (d[FirebaseConstants.fieldProjectId] ?? '').toString(),
      projectTitle: (d[FirebaseConstants.fieldProjectTitle] ?? 'Project')
          .toString(),
      track: (d[FirebaseConstants.fieldTrack] ?? 'Contributor').toString(),
      status: status,
      createdAt: createdAt,
    );
  }

  ApplicantModel _applicantFromDoc(Map<String, dynamic> d) {
    final snap = d[FirebaseConstants.fieldApplicantSnapshot] is Map
        ? Map<String, dynamic>.from(
            d[FirebaseConstants.fieldApplicantSnapshot] as Map,
          )
        : const <String, dynamic>{};
    final rawStatus = (d[FirebaseConstants.fieldStatus] ?? 'pending')
        .toString()
        .toLowerCase();
    final status = switch (rawStatus) {
      'accepted' => ApplicantStatus.accepted,
      'declined' => ApplicantStatus.declined,
      _ => ApplicantStatus.pending,
    };
    final rawSkills = snap[FirebaseConstants.fieldSkills];
    final skills = <String>[
      if (rawSkills is Iterable)
        for (final s in rawSkills) s.toString(),
    ];
    if (skills.isEmpty &&
        (snap[FirebaseConstants.fieldTrack] ?? '').toString().isNotEmpty) {
      skills.add(snap[FirebaseConstants.fieldTrack].toString());
    }
    return ApplicantModel(
      id: (d['id'] ?? '').toString(),
      projectId: (d[FirebaseConstants.fieldProjectId] ?? '').toString(),
      applicantUid: (d[FirebaseConstants.fieldApplicantId] ?? '').toString(),
      name: (snap[FirebaseConstants.fieldName] ?? 'Applicant').toString(),
      title: (snap[FirebaseConstants.fieldTrack] ?? 'Developer').toString(),
      location: (snap['location'] ?? '').toString(),
      level: (snap[FirebaseConstants.fieldLevel] ?? 'Intermediate').toString(),
      username: (snap[FirebaseConstants.fieldPublicId] ?? '').toString(),
      photoUrl: snap[FirebaseConstants.fieldPhotoUrl]?.toString(),
      matchPercent: 88,
      position: (d[FirebaseConstants.fieldTrack] ?? 'Contributor').toString(),
      coverNote:
          (d[FirebaseConstants.fieldPitch] ??
                  'Excited to contribute to this project!')
              .toString(),
      skills: skills,
      status: status,
    );
  }

  DeveloperModel _developerFromDoc(Map<String, dynamic> d) {
    final rawSkills = d[FirebaseConstants.fieldSkills];
    return DeveloperModel(
      id: (d['id'] ?? d[FirebaseConstants.fieldUid] ?? '').toString(),
      name: (d[FirebaseConstants.fieldName] ?? 'Developer').toString(),
      title: (d[FirebaseConstants.fieldTrack] ?? 'Software Engineer')
          .toString(),
      fitPercent: 90,
      skills: rawSkills is Iterable
          ? rawSkills.take(4).map((e) => e.toString()).toList()
          : const ['Flutter'],
    );
  }
}
