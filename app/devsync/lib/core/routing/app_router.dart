import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:devsync/features/auth/presentation/screens/check_inbox_screen.dart';
import 'package:devsync/features/auth/presentation/screens/create_account_screen.dart';
import 'package:devsync/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:devsync/features/auth/presentation/screens/login_screen.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/screens/create_project_screen.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/screens/my_teams_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_board_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_details_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_form_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/team_members_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/team_workspace_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Splash'))),
        );

      case AppRoutes.authEntry:
        return MaterialPageRoute(
          builder: (_) => const AuthEntryScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.createAccount:
        return MaterialPageRoute(
          builder: (_) => const CreateAccountScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.checkInbox:
        final email =
            settings.arguments is String ? settings.arguments as String : '';
        return MaterialPageRoute(
          builder: (_) => CheckInboxScreen(email: email),
          settings: settings,
        );

      case AppRoutes.createProject:
        return MaterialPageRoute(
          builder: (_) => const CreateProjectProviders(
            child: CreateProjectScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.myTeams:
        return MaterialPageRoute(builder: (_) => const MyTeamsScreen(), settings: settings);

      case AppRoutes.teamWorkspace:
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TeamWorkspaceScreen(teamId: team.id), settings: settings);

      case AppRoutes.taskBoard:
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TaskBoardScreen(teamId: team.id), settings: settings);

      case AppRoutes.teamMembers:
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TeamMembersScreen(teamId: team.id), settings: settings);

      case AppRoutes.taskDetails:
        final task = settings.arguments as TaskItem;
        return MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id), settings: settings);

      case AppRoutes.taskCreate:
        final team = settings.arguments as Team;
        return MaterialPageRoute(builder: (_) => TaskFormScreen(teamId: team.id), settings: settings);

      case AppRoutes.taskEdit:
        final task = settings.arguments as TaskItem;
        return MaterialPageRoute(builder: (_) => TaskFormScreen(teamId: task.teamId, taskId: task.id), settings: settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // ================= My Teams Navigation Helpers =================

  static void toWorkspace(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.teamWorkspace, arguments: team);

  static void toTaskBoard(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.taskBoard, arguments: team);

  static void toMembers(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.teamMembers, arguments: team);

  static void toTaskDetails(BuildContext context, TaskItem task) =>
      Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: task);

  static void toCreateTask(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.taskCreate, arguments: team);

  static void toEditTask(BuildContext context, TaskItem task) =>
      Navigator.of(context).pushNamed(AppRoutes.taskEdit, arguments: task);

  static void backToRoot(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);
}
