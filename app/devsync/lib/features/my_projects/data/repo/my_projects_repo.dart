import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart'
    as discover;
import '../models/applicant_model.dart';
import '../models/developer_model.dart';
import '../models/invitation_model.dart';
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
          final pid = (tDoc[FirebaseConstants.fieldProjectId] ?? tDoc['id'] ?? '')
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

        if (byId.isNotEmpty) return byId.values.toList();
      } catch (_) {}
    }
    return _fallbackProjects();
  }

  // Fetch incoming project invitations for the current user.
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
        if (docs.isNotEmpty) {
          return docs.map(_invitationFromDoc).toList();
        }
      } catch (_) {}
    }
    return _fallbackInvitations();
  }

  // Fetch incoming join requests across the user's owned projects.
  Future<List<ApplicantModel>> getApplicants({
    List<String> ownedProjectIds = const [],
  }) async {
    final fs = _firestore;
    if (fs != null && ownedProjectIds.isNotEmpty) {
      try {
        final results = <ApplicantModel>[];
        for (final pid in ownedProjectIds.take(10)) {
          final docs = await fs.getCollection(
            collectionPath: FirebaseConstants.requestsCollection,
            queryBuilder: (q) =>
                q.where(FirebaseConstants.fieldProjectId, isEqualTo: pid),
          );
          results.addAll(docs.map(_applicantFromDoc));
        }
        if (results.isNotEmpty) return results;
      } catch (_) {}
    }
    return _fallbackApplicants();
  }

  // Fetch recommended developers to invite.
  Future<List<DeveloperModel>> getDevelopers() async {
    final uid = _auth?.currentUserId;
    final fs = _firestore;
    if (fs != null) {
      try {
        final docs = await fs.getCollection(
          collectionPath: FirebaseConstants.usersCollection,
        );
        final mapped = docs
            .where((d) => (d['id'] ?? d[FirebaseConstants.fieldUid]) != uid)
            .take(10)
            .map(_developerFromDoc)
            .toList();
        if (mapped.isNotEmpty) return mapped;
      } catch (_) {}
    }
    return _fallbackDevelopers();
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

  // Persist applicant decision, increment filledCount, and add member to teams/{projectId}.
  Future<void> respondToApplicant(
    ApplicantModel applicant,
    bool accept, {
    int? updatedMembersCount,
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
        if (updatedMembersCount != null) {
          await fs.updateDocument(
            collectionPath: FirebaseConstants.projectsCollection,
            docId: applicant.projectId,
            data: {
              FirebaseConstants.fieldFilledCount: updatedMembersCount,
              FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
            },
          );
        }
        final memberUid = applicant.applicantUid.isNotEmpty
            ? applicant.applicantUid
            : applicant.id;
        final handle = applicant.username.isNotEmpty
            ? applicant.username
            : applicant.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
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

  // Publish a saved draft project (draft -> open).
  Future<void> publishDraft(String projectId) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: projectId,
        data: {
          FirebaseConstants.fieldStatus: 'open',
          FirebaseConstants.fieldPublishedAt: fs.serverTimestamp,
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
      );
    } catch (_) {}
  }

  // Delete a draft project from Firestore.
  Future<void> deleteProject(String projectId) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.deleteDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: projectId,
      );
    } catch (_) {}
  }

  // Update project lifecycle status (archived or open).
  Future<void> setProjectArchived(String projectId, bool archived) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs.updateDocument(
        collectionPath: FirebaseConstants.projectsCollection,
        docId: projectId,
        data: {
          FirebaseConstants.fieldStatus: archived ? 'archived' : 'open',
          FirebaseConstants.fieldUpdatedAt: fs.serverTimestamp,
        },
      );
    } catch (_) {}
  }

  ProjectModel _projectFromDoc(Map<String, dynamic> d, String uid) {
    final status = (d[FirebaseConstants.fieldStatus] ?? 'open')
        .toString()
        .toLowerCase();
    final isDraft = status == 'draft';
    final isPrevious = status == 'archived' || status == 'completed';
    final rawTags = d[FirebaseConstants.fieldTechStack];
    final rawOpen = d[FirebaseConstants.fieldOpenTrackKeys];
    final repoUrl = (d['repoUrl'] ?? '').toString();
    final cloneUrl = (d['cloneUrl'] ?? ProjectModel.deriveCloneUrl(repoUrl))
        .toString();
    final rawRules = d['gitRules'];

    return ProjectModel(
      id: (d['id'] ?? '').toString(),
      name: (d[FirebaseConstants.fieldTitle] ?? 'Untitled Project').toString(),
      description: (d[FirebaseConstants.fieldDescription] ?? '').toString(),
      statusText: isDraft
          ? 'Draft'
          : isPrevious
          ? (status == 'completed' ? 'Completed' : 'Archived')
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
      note: (d[FirebaseConstants.fieldMessage] ??
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
      coverNote: (d[FirebaseConstants.fieldPitch] ??
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
      title: (d[FirebaseConstants.fieldTrack] ?? 'Software Engineer').toString(),
      fitPercent: 90,
      skills: rawSkills is Iterable
          ? rawSkills.take(4).map((e) => e.toString()).toList()
          : const ['Flutter'],
    );
  }

  List<ProjectModel> _fallbackProjects() => [
    ProjectModel(
      id: 'eco',
      name: 'EcoTrack Mobile',
      description:
          'Real-time carbon telemetry and sensor analytics for smart buildings over Bluetooth Low Energy.',
      statusText: 'Active • Sprint 2',
      isOwner: true,
      membersCount: 3,
      totalSeats: 5,
      tags: ['BLE v5.3', 'SQLite Sync', 'MIT License'],
      openRoles: ['Backend / SQLite Architect', 'BLE Telemetry Integrator'],
      repoUrl: 'https://github.com/ecotrack/mobile',
      cloneUrl: 'https://github.com/ecotrack/mobile.git',
      defaultBranch: 'develop',
      gitRules: const GitWorkflowRules(
        customRules: ['Run flutter analyze before opening any Pull Request'],
      ),
    ),
    ProjectModel(
      id: 'algo',
      name: 'AlgoViz Flutter',
      description: 'Algorithm visualizer built with Flutter canvas.',
      statusText: 'Active • v1.2',
      isOwner: false,
      membersCount: 4,
      totalSeats: 4,
      tags: ['Flutter', 'Canvas'],
      openRoles: [],
      repoUrl: 'https://github.com/algoviz/flutter',
      cloneUrl: 'https://github.com/algoviz/flutter.git',
      defaultBranch: 'main',
    ),
    ProjectModel(
      id: 'p3',
      name: 'CloudMesh Go',
      description: 'Distributed mesh network tooling written in Go.',
      statusText: 'Planning',
      isOwner: true,
      membersCount: 1,
      totalSeats: 4,
      tags: ['Go', 'gRPC'],
      openRoles: ['Go Systems Engineer'],
      repoUrl: 'https://github.com/cloudmesh/go-cli',
      cloneUrl: 'https://github.com/cloudmesh/go-cli.git',
      defaultBranch: 'develop',
    ),
    ProjectModel(
      id: 'p4',
      name: 'KubeLens Mobile',
      description: 'Shipped v1.0 release with 1,200 stars on GitHub.',
      statusText: 'Completed',
      isOwner: false,
      membersCount: 5,
      totalSeats: 5,
      tags: ['Flutter'],
      openRoles: [],
      period: 'Jan 2024 - Jun 2024 (6 mos)',
      type: ProjectType.previous,
      repoUrl: 'https://github.com/kubelens/mobile',
      cloneUrl: 'https://github.com/kubelens/mobile.git',
      defaultBranch: 'main',
    ),
    ProjectModel(
      id: 'p5',
      name: 'RustAudio Engine',
      description: 'Archived after core goals were fulfilled.',
      statusText: 'Archived',
      isOwner: true,
      membersCount: 3,
      totalSeats: 3,
      tags: ['Rust'],
      openRoles: [],
      period: 'Sep 2023 - Dec 2023',
      type: ProjectType.previous,
      repoUrl: 'https://github.com/rustaudio/engine',
      cloneUrl: 'https://github.com/rustaudio/engine.git',
      defaultBranch: 'main',
    ),
    ProjectModel(
      id: 'p6',
      name: 'DevSync AI Reviewer',
      description: 'Automated PR feedback bot checking architecture rules and lint checks.',
      statusText: 'Draft',
      isOwner: true,
      membersCount: 1,
      totalSeats: 3,
      tags: ['Python', 'FastAPI', 'GitHub API'],
      openRoles: ['Backend Engineer', 'ML Engineer'],
      type: ProjectType.draft,
      defaultBranch: 'develop',
    ),
  ];

  List<InvitationModel> _fallbackInvitations() => [
    InvitationModel(
      id: 'i1',
      projectName: 'NeuroPulse Swift',
      ownerName: 'Elena Rostova',
      ownerRole: 'Core Maintainer',
      note:
          'We saw your work on signal processing and think you would be a great fit for our team.',
      role: 'Core iOS / Metal',
      hoursPerWeek: '8-10 hrs / wk',
      level: 'Mid - Senior',
      responsibilities: [
        'Build real-time EEG signal processing',
        'Write Metal shaders for visualization',
      ],
      skills: ['Swift', 'Metal Shader', 'DSP'],
    ),
    InvitationModel(
      id: 'i2',
      projectName: 'DevKube CLI',
      ownerName: 'David Chen',
      ownerRole: 'Project Lead',
      note: 'Your Go experience is exactly what we need for the CLI.',
      role: 'Go Systems',
      hoursPerWeek: '6-8 hrs / wk',
      level: 'Mid',
      responsibilities: [
        'Develop multi-cluster debugging commands',
        'Write unit tests',
      ],
      skills: ['Go', 'Kubernetes', 'gRPC'],
    ),
  ];

  List<ApplicantModel> _fallbackApplicants() => [
    ApplicantModel(
      id: 'a1',
      projectId: 'eco',
      applicantUid: 'u_liam',
      name: "Liam O'Connor",
      title: 'Senior Mobile Backend Developer',
      location: 'Dublin, IE',
      level: 'Senior',
      username: '@liamoconnor',
      matchPercent: 94,
      position: 'Backend / SQLite Architect',
      coverNote:
          'I have been tracking EcoTrack Mobile since the RFC. I previously built offline-first telemetry caching in SQLite and can dedicate 8 hrs/week.',
      skills: ['SQLite', 'Drift', 'Dart Isolates'],
    ),
    ApplicantModel(
      id: 'a2',
      projectId: 'eco',
      applicantUid: 'u_amina',
      name: 'Amina Al-Mansour',
      title: 'QA Automation Engineer',
      location: 'Toronto, CA',
      level: 'Mid-Level',
      username: '@amina_qa',
      matchPercent: 89,
      position: 'Integration & QA Contributor',
      coverNote:
          'I would love to write golden widget tests and automate BLE test mocks.',
      skills: ['Flutter Test', 'Mocktail', 'CI/CD'],
    ),
  ];

  List<DeveloperModel> _fallbackDevelopers() => [
    DeveloperModel(
      id: 'd1',
      name: 'Sofia Chen',
      title: 'Senior Distributed Systems & Dart Engineer',
      fitPercent: 96,
      skills: ['Dart', 'C++ FFI', 'BLE'],
    ),
    DeveloperModel(
      id: 'd2',
      name: 'Omar Hassan',
      title: 'Flutter & Firebase Architect',
      fitPercent: 91,
      skills: ['Flutter', 'Firebase', 'BLoC'],
    ),
  ];
}
