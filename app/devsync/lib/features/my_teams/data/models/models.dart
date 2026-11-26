import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:flutter/material.dart';

// Task priority levels.
enum Priority { low, medium, high }

// Task progression statuses.
enum TaskStatus { todo, inProgress, inReview, done }

// Team member roles for RBAC.
enum TeamRole { owner, trackLeader, member }

// Extension for team role labels & serialization.
extension TeamRoleX on TeamRole {
  String get label => switch (this) {
    TeamRole.owner => 'Project Owner',
    TeamRole.trackLeader => 'Track Leader',
    TeamRole.member => 'Member',
  };

  String get shortLabel => switch (this) {
    TeamRole.owner => 'Owner',
    TeamRole.trackLeader => 'Track Leader',
    TeamRole.member => 'Member',
  };

  static TeamRole fromName(String? raw, {bool isOwnerFlag = false}) {
    if (isOwnerFlag) return TeamRole.owner;
    return switch ((raw ?? '').trim().toLowerCase()) {
      'owner' || 'project owner' => TeamRole.owner,
      'trackleader' || 'track_leader' || 'track leader' => TeamRole.trackLeader,
      _ => TeamRole.member,
    };
  }
}

// Configurable permissions granted to a team role.
class RolePermissions {
  const RolePermissions({
    required this.createEditTasks,
    required this.assignTasks,
    required this.deleteTasks,
    required this.approveTasks,
    required this.inviteMembers,
    required this.viewAllTasks,
  });

  final bool createEditTasks;
  final bool assignTasks;
  final bool deleteTasks;
  final bool approveTasks;
  final bool inviteMembers;
  final bool viewAllTasks;

  static const RolePermissions ownerAll = RolePermissions(
    createEditTasks: true,
    assignTasks: true,
    deleteTasks: true,
    approveTasks: true,
    inviteMembers: true,
    viewAllTasks: true,
  );

  static const RolePermissions defaultTrackLeader = RolePermissions(
    createEditTasks: true,
    assignTasks: true,
    deleteTasks: false,
    approveTasks: true,
    inviteMembers: true,
    viewAllTasks: true,
  );

  static const RolePermissions defaultMember = RolePermissions(
    createEditTasks: false,
    assignTasks: false,
    deleteTasks: false,
    approveTasks: false,
    inviteMembers: false,
    viewAllTasks: false,
  );

  RolePermissions copyWith({
    bool? createEditTasks,
    bool? assignTasks,
    bool? deleteTasks,
    bool? approveTasks,
    bool? inviteMembers,
    bool? viewAllTasks,
  }) => RolePermissions(
    createEditTasks: createEditTasks ?? this.createEditTasks,
    assignTasks: assignTasks ?? this.assignTasks,
    deleteTasks: deleteTasks ?? this.deleteTasks,
    approveTasks: approveTasks ?? this.approveTasks,
    inviteMembers: inviteMembers ?? this.inviteMembers,
    viewAllTasks: viewAllTasks ?? this.viewAllTasks,
  );

  Map<String, dynamic> toMap() => {
    'createEditTasks': createEditTasks,
    'assignTasks': assignTasks,
    'deleteTasks': deleteTasks,
    'approveTasks': approveTasks,
    'inviteMembers': inviteMembers,
    'viewAllTasks': viewAllTasks,
  };

  factory RolePermissions.fromMap(
    Map<String, dynamic>? map, {
    required RolePermissions fallback,
  }) {
    if (map == null) return fallback;
    return RolePermissions(
      createEditTasks: map['createEditTasks'] as bool? ?? fallback.createEditTasks,
      assignTasks: map['assignTasks'] as bool? ?? fallback.assignTasks,
      deleteTasks: map['deleteTasks'] as bool? ?? fallback.deleteTasks,
      approveTasks: map['approveTasks'] as bool? ?? fallback.approveTasks,
      inviteMembers: map['inviteMembers'] as bool? ?? fallback.inviteMembers,
      viewAllTasks: map['viewAllTasks'] as bool? ?? fallback.viewAllTasks,
    );
  }
}

// Governance & workflow configuration for a team workspace.
class TeamSettings {
  const TeamSettings({
    this.requirePrCheck = true,
    this.inviteOnly = true,
    this.trackLeaderPermissions = RolePermissions.defaultTrackLeader,
    this.memberPermissions = RolePermissions.defaultMember,
  });

  final bool requirePrCheck;
  final bool inviteOnly;
  final RolePermissions trackLeaderPermissions;
  final RolePermissions memberPermissions;

  RolePermissions permissionsFor(TeamRole role) => switch (role) {
    TeamRole.owner => RolePermissions.ownerAll,
    TeamRole.trackLeader => trackLeaderPermissions,
    TeamRole.member => memberPermissions,
  };

  TeamSettings copyWith({
    bool? requirePrCheck,
    bool? inviteOnly,
    RolePermissions? trackLeaderPermissions,
    RolePermissions? memberPermissions,
  }) => TeamSettings(
    requirePrCheck: requirePrCheck ?? this.requirePrCheck,
    inviteOnly: inviteOnly ?? this.inviteOnly,
    trackLeaderPermissions:
        trackLeaderPermissions ?? this.trackLeaderPermissions,
    memberPermissions: memberPermissions ?? this.memberPermissions,
  );

  Map<String, dynamic> toMap() => {
    'requirePrCheck': requirePrCheck,
    'inviteOnly': inviteOnly,
    'trackLeaderPermissions': trackLeaderPermissions.toMap(),
    'memberPermissions': memberPermissions.toMap(),
  };

  factory TeamSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const TeamSettings();
    return TeamSettings(
      requirePrCheck: map['requirePrCheck'] as bool? ?? true,
      inviteOnly: map['inviteOnly'] as bool? ?? true,
      trackLeaderPermissions: RolePermissions.fromMap(
        map['trackLeaderPermissions'] is Map
            ? Map<String, dynamic>.from(map['trackLeaderPermissions'] as Map)
            : null,
        fallback: RolePermissions.defaultTrackLeader,
      ),
      memberPermissions: RolePermissions.fromMap(
        map['memberPermissions'] is Map
            ? Map<String, dynamic>.from(map['memberPermissions'] as Map)
            : null,
        fallback: RolePermissions.defaultMember,
      ),
    );
  }
}

// Extension for task status labels & serialization.
extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.inReview => 'In Review',
    TaskStatus.done => 'Done',
  };

  static TaskStatus fromName(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'inprogress' || 'in_progress' => TaskStatus.inProgress,
      'inreview' || 'in_review' => TaskStatus.inReview,
      'done' => TaskStatus.done,
      _ => TaskStatus.todo,
    };
  }
}

// Extension for priority labels & serialization.
extension PriorityX on Priority {
  String get label => switch (this) {
    Priority.low => 'Low',
    Priority.medium => 'Medium',
    Priority.high => 'High',
  };

  static Priority fromName(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'low' => Priority.low,
      'high' => Priority.high,
      _ => Priority.medium,
    };
  }
}

// Team member representation.
class Member {
  const Member({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    this.teamRole = TeamRole.member,
    this.alsoTrackLeader = false,
    this.leaderTrack,
    bool? isOwner,
  }) : _isOwnerOverride = isOwner;

  final String id;
  final String name;
  final String handle;
  final String role;
  final TeamRole teamRole;
  final bool alsoTrackLeader;
  final String? leaderTrack;
  final bool? _isOwnerOverride;

  bool get isOwner => _isOwnerOverride ?? teamRole == TeamRole.owner;
  bool get isTrackLeader =>
      teamRole == TeamRole.trackLeader || alsoTrackLeader;

  TeamRole get effectiveRole => isOwner ? TeamRole.owner : teamRole;

  // Specific leader badge label (e.g. "Flutter Leader" or fallback "Track Leader").
  String get leaderBadgeLabel {
    final t = leaderTrack?.trim() ?? '';
    if (t.isEmpty) return TeamRole.trackLeader.shortLabel;
    return t.toLowerCase().endsWith('leader') ? t : '$t Leader';
  }

  // Primary role badge label for member tiles.
  String get roleBadgeLabel => switch (effectiveRole) {
    TeamRole.owner => TeamRole.owner.shortLabel,
    TeamRole.trackLeader => leaderBadgeLabel,
    TeamRole.member => TeamRole.member.shortLabel,
  };

  Member copyWith({
    String? name,
    String? handle,
    String? role,
    TeamRole? teamRole,
    bool? alsoTrackLeader,
    String? leaderTrack,
    bool clearLeaderTrack = false,
  }) => Member(
    id: id,
    name: name ?? this.name,
    handle: handle ?? this.handle,
    role: role ?? this.role,
    teamRole: teamRole ?? effectiveRole,
    alsoTrackLeader: alsoTrackLeader ?? this.alsoTrackLeader,
    leaderTrack: clearLeaderTrack ? null : (leaderTrack ?? this.leaderTrack),
  );

  // Safe initials derived from non-empty name tokens.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory Member.fromFirestore(Map<String, dynamic> data) {
    final uid = (data[FirebaseConstants.fieldUid] ?? data['id'] ?? '')
        .toString();
    final rawName = (data[FirebaseConstants.fieldName] ?? 'Member').toString();
    final rawHandle =
        (data['username'] ?? data[FirebaseConstants.fieldPublicId] ?? '')
            .toString()
            .trim();
    final parsedRole = TeamRoleX.fromName(
      data['teamRole']?.toString(),
      isOwnerFlag: data[FirebaseConstants.fieldIsOwner] == true,
    );
    final rawTrack = data['leaderTrack']?.toString().trim();
    return Member(
      id: uid,
      name: rawName.trim().isEmpty ? 'Member' : rawName.trim(),
      handle: rawHandle.isEmpty
          ? '@member'
          : (rawHandle.startsWith('@') ? rawHandle : '@$rawHandle'),
      role: (data[FirebaseConstants.fieldTrack] ?? data['role'] ?? 'Contributor')
          .toString(),
      teamRole: parsedRole,
      alsoTrackLeader: data['alsoTrackLeader'] == true,
      leaderTrack: (rawTrack != null && rawTrack.isNotEmpty) ? rawTrack : null,
    );
  }
}

// Open vacancy or role within a team.
class OpenRole {
  const OpenRole({
    required this.title,
    required this.description,
    required this.level,
    required this.hours,
    required this.tech,
  });

  final String title;
  final String description;
  final String level;
  final String hours;
  final String tech;
}

// Acceptance criterion checklist item.
class Criterion {
  Criterion(this.text, {this.done = false});

  String text;
  bool done;

  Map<String, dynamic> toMap() => {'text': text, 'done': done};

  factory Criterion.fromMap(Map<String, dynamic> map) => Criterion(
    (map['text'] ?? '').toString(),
    done: map['done'] == true,
  );
}

// Task details model.
class TaskItem {
  TaskItem({
    required this.id,
    required this.teamId,
    required this.number,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.assignee,
    this.dueDate,
    this.tag = 'General',
    this.epic = 'GENERAL',
    List<Criterion>? criteria,
    this.comment,
    this.commentBy,
    this.codePath,
    this.prUrl,
    this.reviewNote,
  }) : criteria = criteria ?? [];

  final String id;
  final String teamId;
  final int number;
  String title;
  String description;
  Priority priority;
  TaskStatus status;
  Member? assignee;
  DateTime? dueDate;
  String tag;
  String epic;
  List<Criterion> criteria;
  String? comment;
  String? commentBy;
  String? codePath;
  String? prUrl;
  String? reviewNote;

  // Derived subtask progress synced directly with acceptance criteria.
  int get subtasksDone => criteria.where((c) => c.done).length;
  int get subtasksTotal => criteria.length;
  bool get allCriteriaDone => criteria.isEmpty || criteria.every((c) => c.done);

  bool get isOverdue =>
      dueDate != null &&
      status != TaskStatus.done &&
      dueDate!.isBefore(DateTime.now());

  Map<String, dynamic> toFirestore({required String createdBy}) => {
    FirebaseConstants.fieldTitle: title,
    FirebaseConstants.fieldDescription: description,
    FirebaseConstants.fieldTaskPriority: priority.name,
    FirebaseConstants.fieldStatus: status.name,
    FirebaseConstants.fieldTaskAssigneeId: assignee?.id,
    FirebaseConstants.fieldTaskDeadline: dueDate?.toIso8601String(),
    FirebaseConstants.fieldTaskCreatedBy: createdBy,
    'number': number,
    'tag': tag,
    'epic': epic,
    'criteria': criteria.map((c) => c.toMap()).toList(),
    'codePath': codePath,
    'prUrl': prUrl,
    'reviewNote': reviewNote,
    'comment': comment,
    'commentBy': commentBy,
  };

  factory TaskItem.fromFirestore(
    Map<String, dynamic> data, {
    required String teamId,
    required List<Member> members,
    int fallbackNumber = 1,
  }) {
    final assigneeId = data[FirebaseConstants.fieldTaskAssigneeId]?.toString();
    final assignee = (assigneeId == null || assigneeId.isEmpty)
        ? null
        : members.where((m) => m.id == assigneeId).firstOrNull;

    final rawCriteria = data['criteria'];
    final parsedCriteria = <Criterion>[
      if (rawCriteria is Iterable)
        for (final item in rawCriteria)
          if (item is Map)
            Criterion.fromMap(Map<String, dynamic>.from(item)),
    ];

    return TaskItem(
      id: (data['id'] ?? '').toString(),
      teamId: teamId,
      number: (data['number'] is num)
          ? (data['number'] as num).toInt()
          : fallbackNumber,
      title: (data[FirebaseConstants.fieldTitle] ?? 'Untitled Task').toString(),
      description: (data[FirebaseConstants.fieldDescription] ?? '').toString(),
      priority: PriorityX.fromName(
        data[FirebaseConstants.fieldTaskPriority]?.toString(),
      ),
      status: TaskStatusX.fromName(
        data[FirebaseConstants.fieldStatus]?.toString(),
      ),
      assignee: assignee,
      dueDate: _parseDate(data[FirebaseConstants.fieldTaskDeadline]),
      tag: (data['tag'] ?? 'General').toString(),
      epic: (data['epic'] ?? 'GENERAL').toString(),
      criteria: parsedCriteria,
      codePath: data['codePath']?.toString(),
      prUrl: data['prUrl']?.toString(),
      reviewNote: data['reviewNote']?.toString(),
      comment: data['comment']?.toString(),
      commentBy: data['commentBy']?.toString(),
    );
  }
}

// Team workspace model.
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.role,
    required this.sprint,
    required this.icon,
    required this.members,
    required this.totalSeats,
    required this.openRoles,
    required this.version,
    required this.repoUrl,
    this.ownerId = '',
    this.expectedEndDate,
    this.settings = const TeamSettings(),
    this.projectTracks = const [],
  });

  final String id;
  final String name;
  final String subtitle;
  final String role;
  final String sprint;
  final IconData icon;
  final List<Member> members;
  final int totalSeats;
  final List<OpenRole> openRoles;
  final String version;
  final String repoUrl;
  final String ownerId;
  final DateTime? expectedEndDate;
  final TeamSettings settings;
  final List<String> projectTracks;

  bool get isOwner => role == 'Owner' || role == 'Project Owner';

  // Project-scoped tracks available for assigning Track Leaders.
  List<String> get availableTracks {
    final seen = <String>{};
    final tracks = <String>[];
    void addTrack(String raw) {
      final clean = raw.trim();
      if (clean.isEmpty) return;
      final key = clean.toLowerCase();
      if (seen.add(key)) tracks.add(clean);
    }

    for (final t in projectTracks) {
      addTrack(t);
    }
    for (final m in members) {
      if (m.leaderTrack != null) addTrack(m.leaderTrack!);
    }
    if (tracks.isEmpty) {
      for (final m in members) {
        final primary = m.role.split(RegExp(r'[&,/]')).first.trim();
        if (primary.isNotEmpty && primary.toLowerCase() != 'project owner') {
          addTrack(primary);
        }
      }
      for (final r in openRoles) {
        final primary = r.title.split(RegExp(r'[&,/]')).first.trim();
        if (primary.isNotEmpty) addTrack(primary);
      }
    }
    return tracks;
  }

  int? get daysRemaining {
    if (expectedEndDate == null) return null;
    final diff = expectedEndDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  Team copyWith({
    String? name,
    String? subtitle,
    String? role,
    String? sprint,
    List<Member>? members,
    int? totalSeats,
    List<OpenRole>? openRoles,
    String? version,
    String? repoUrl,
    String? ownerId,
    DateTime? expectedEndDate,
    TeamSettings? settings,
    List<String>? projectTracks,
  }) => Team(
    id: id,
    name: name ?? this.name,
    subtitle: subtitle ?? this.subtitle,
    role: role ?? this.role,
    sprint: sprint ?? this.sprint,
    icon: icon,
    members: members ?? this.members,
    totalSeats: totalSeats ?? this.totalSeats,
    openRoles: openRoles ?? this.openRoles,
    version: version ?? this.version,
    repoUrl: repoUrl ?? this.repoUrl,
    ownerId: ownerId ?? this.ownerId,
    expectedEndDate: expectedEndDate ?? this.expectedEndDate,
    settings: settings ?? this.settings,
    projectTracks: projectTracks ?? this.projectTracks,
  );
}

DateTime? _parseDate(dynamic raw) {
  if (raw == null) return null;
  if (raw is Timestamp) return raw.toDate();
  if (raw is DateTime) return raw;
  if (raw is String && raw.trim().isNotEmpty) return DateTime.tryParse(raw);
  return null;
}
