import 'package:flutter/material.dart';

// Task priority levels
enum Priority { low, medium, high }

// Task progression statuses
enum TaskStatus { todo, inProgress, inReview, done }

// Extension for task status labels
extension TaskStatusX on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'To Do',
        TaskStatus.inProgress => 'In Progress',
        TaskStatus.inReview => 'In Review',
        TaskStatus.done => 'Done',
      };
}

// Extension for priority labels
extension PriorityX on Priority {
  String get label => switch (this) {
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
      };
}

// Team member representation
class Member {
  final String id;
  final String name;
  final String handle;
  final String role;
  final bool isOwner;

  const Member({
    required this.id,
    required this.name,
    required this.handle,
    required this.role,
    this.isOwner = false,
  });

  // Initials from full name
  String get initials {
    final p = name.trim().split(' ');
    return (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
  }
}

// Open vacancy or role within a team
class OpenRole {
  final String title;
  final String description;
  final String level;
  final String hours;
  final String tech;

  const OpenRole({
    required this.title,
    required this.description,
    required this.level,
    required this.hours,
    required this.tech,
  });
}

// Acceptance criterion checklist item
class Criterion {
  String text;
  bool done;

  Criterion(this.text, {this.done = false});
}

// Task details model
class TaskItem {
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
  int subtasksDone;
  int subtasksTotal;
  List<Criterion> criteria;
  String? comment;
  String? commentBy;
  String? codePath;

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
    this.subtasksDone = 0,
    this.subtasksTotal = 0,
    List<Criterion>? criteria,
    this.comment,
    this.commentBy,
    this.codePath,
  }) : criteria = criteria ?? [];
}

// Team workspace model
class Team {
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
  });

  bool get isOwner => role == 'Owner';
}
