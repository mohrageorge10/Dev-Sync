import 'package:flutter/material.dart';
import './models/models.dart';

// Central state management for teams and tasks
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  late final Member me;
  late final List<Member> people;
  final List<Team> _teams = [];
  final List<TaskItem> _tasks = [];
  int _nextNumber = 104;

  List<Team> get teams => List.unmodifiable(_teams);

  Team teamById(String id) => _teams.firstWhere((t) => t.id == id);

  List<TaskItem> tasksOf(String teamId) =>
      _tasks.where((t) => t.teamId == teamId).toList();

  TaskItem taskById(String id) => _tasks.firstWhere((t) => t.id == id);

  int openTasksCount(String teamId) =>
      tasksOf(teamId).where((t) => t.status != TaskStatus.done).length;

  ({int done, int total}) progressOf(String teamId) {
    final l = tasksOf(teamId);
    return (
      done: l.where((t) => t.status == TaskStatus.done).length,
      total: l.length
    );
  }

  int get peekNextNumber => _nextNumber;

  int nextNumber() => _nextNumber++;

  void saveTask(TaskItem task) {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) {
      _tasks.add(task);
    } else {
      _tasks[i] = task;
    }
    notifyListeners();
  }

  void setStatus(String id, TaskStatus s) {
    taskById(id).status = s;
    notifyListeners();
  }

  void toggleCriterion(String id, int index) {
    final c = taskById(id).criteria[index];
    c.done = !c.done;
    notifyListeners();
  }

  void leaveTeam(String id) {
    _teams.removeWhere((t) => t.id == id);
    _tasks.removeWhere((t) => t.teamId == id);
    notifyListeners();
  }

  // Seed initial mock data
  void _seed() {
    me = const Member(
        id: 'u1',
        name: 'Alex Rivera',
        handle: '@alexrivera',
        role: 'Project Owner & BLE Lead',
        isOwner: true);
    const sarah = Member(
        id: 'u2',
        name: 'Sarah Lin',
        handle: '@sarahlin_dev',
        role: 'UI/UX & Design Systems');
    const marcus = Member(
        id: 'u3',
        name: 'Marcus Vance',
        handle: '@marcus_v',
        role: 'Flutter Client & State');
    const sofia = Member(
        id: 'u4',
        name: 'Sofia Chen',
        handle: '@sofia_c',
        role: 'QA & Test Automation');
    people = [me, sarah, marcus, sofia];

    _teams.addAll([
      Team(
        id: 'eco',
        name: 'EcoTrack Mobile',
        subtitle: 'Active • Real-world',
        role: 'Owner',
        sprint: 'Sprint 2',
        icon: Icons.eco_outlined,
        members: [me, sarah, marcus],
        totalSeats: 5,
        version: 'v2.4.0',
        repoUrl: 'github.com/ecotrack/mobile',
        openRoles: const [
          OpenRole(
              title: 'Backend / SQLite Architect',
              description:
                  'Local-first sync engine & telemetry persistence layer',
              level: 'Intermediate',
              hours: '8 hrs/wk',
              tech: 'SQLite & Drift'),
          OpenRole(
              title: 'Integration & QA Contributor',
              description:
                  'Automated unit test runs, widget harnesses & edge cases',
              level: 'Beginner friendly',
              hours: '4 hrs/wk',
              tech: 'Integration Testing'),
        ],
      ),
      Team(
        id: 'algo',
        name: 'AlgoViz Flutter',
        subtitle: 'Active • Learning',
        role: 'Member',
        sprint: 'v1.2 Release',
        icon: Icons.account_tree_outlined,
        members: [sarah, marcus],
        totalSeats: 4,
        version: 'v1.2.0',
        repoUrl: 'github.com/algoviz/flutter',
        openRoles: const [],
      ),
    ]);

    final now = DateTime.now();
    _tasks.addAll([
      TaskItem(
        id: 't12',
        teamId: 'eco',
        number: 12,
        title: 'Refactor BLE background isolate connection lifecycle',
        description:
            'Ensure persistent peripheral handshake reconnects cleanly when Android battery saver triggers deep doze.',
        priority: Priority.high,
        status: TaskStatus.inProgress,
        assignee: me,
        dueDate: now.add(const Duration(days: 2)),
        tag: 'Architecture',
        epic: 'BLE & STATE MANAGEMENT',
        subtasksDone: 3,
        subtasksTotal: 4,
        codePath: 'lib/core/ble/isolate_worker.dart',
        criteria: [
          Criterion('StreamController closed on dispose', done: true),
          Criterion('GATT disconnect timeout verified (5s)'),
          Criterion('Tested on Android 14 physical device'),
        ],
        comment: 'Added the missing GATT disconnect timeout spec...',
        commentBy: 'Sofia Chen',
      ),
      TaskItem(
        id: 't14',
        teamId: 'eco',
        number: 14,
        title: 'Implement telemetry sync charts with FL Chart',
        description:
            'Render kilowatt-hour smoothing spline with real-time scrub interaction & export vector snapshots.',
        priority: Priority.medium,
        status: TaskStatus.inProgress,
        assignee: sarah,
        dueDate: now.add(const Duration(days: 8)),
        tag: 'UI/UX',
        epic: 'TELEMETRY',
        subtasksDone: 1,
        subtasksTotal: 3,
        criteria: [Criterion('Chart scrubs at 60fps')],
      ),
      TaskItem(
        id: 't16',
        teamId: 'eco',
        number: 16,
        title: 'Profile SQLite WAL mode buffer allocations on cold start',
        priority: Priority.low,
        tag: 'Performance',
        epic: 'PERFORMANCE',
      ),
      TaskItem(
        id: 't17',
        teamId: 'eco',
        number: 17,
        title: 'Add dark mode tokens to design system',
        description: 'Map semantic color tokens for dark surfaces.',
        priority: Priority.medium,
        assignee: sarah,
        dueDate: now.add(const Duration(days: 12)),
        tag: 'UI/UX',
        epic: 'DESIGN SYSTEM',
      ),
      TaskItem(
        id: 't18',
        teamId: 'eco',
        number: 18,
        title: 'Write widget tests for onboarding flow',
        priority: Priority.low,
        assignee: sofia,
        dueDate: now.add(const Duration(days: 6)),
        tag: 'Testing',
        epic: 'QUALITY',
      ),
      TaskItem(
        id: 't11',
        teamId: 'eco',
        number: 11,
        title: 'Migrate state layer to ChangeNotifier',
        description:
            'Replace ad-hoc setState usage with a single source of truth.',
        priority: Priority.high,
        status: TaskStatus.inReview,
        assignee: marcus,
        dueDate: now.add(const Duration(days: 1)),
        tag: 'Architecture',
        epic: 'BLE & STATE MANAGEMENT',
        subtasksDone: 4,
        subtasksTotal: 4,
      ),
      TaskItem(
        id: 't9',
        teamId: 'eco',
        number: 9,
        title: 'Set up CI pipeline',
        priority: Priority.medium,
        status: TaskStatus.done,
        assignee: me,
        tag: 'DevOps',
        epic: 'INFRA',
      ),
      TaskItem(
        id: 'a3',
        teamId: 'algo',
        number: 3,
        title: 'Animate quick sort partitions',
        priority: Priority.medium,
        status: TaskStatus.inProgress,
        assignee: me,
        dueDate: now.add(const Duration(days: 4)),
        tag: 'Visualization',
        epic: 'SORTING',
      ),
      TaskItem(
        id: 'a4',
        teamId: 'algo',
        number: 4,
        title: 'Add speed slider to playback controls',
        priority: Priority.low,
        tag: 'UI/UX',
        epic: 'PLAYBACK',
      ),
    ]);
  }
}

// InheritedNotifier providing AppState down the widget tree
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
