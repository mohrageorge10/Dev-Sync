import 'dart:typed_data';

import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/static/on_boarding/screens/on_boarding.dart';
import 'package:devsync/core/static/splash/Splash.dart';
import 'package:devsync/features/ai_match/business_logic/match_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_cubit.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/screens/match_history_screen.dart';
import 'package:devsync/features/ai_match/screens/skill_gap_screen.dart';
import 'package:devsync/features/ai_match/screens/why_this_fits_screen.dart';
import 'package:devsync/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:devsync/features/auth/presentation/screens/check_inbox_screen.dart';
import 'package:devsync/features/auth/presentation/screens/create_account_screen.dart';
import 'package:devsync/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:devsync/features/auth/presentation/screens/legal_document_screen.dart';
import 'package:devsync/features/auth/presentation/screens/login_screen.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/screens/create_project_screen.dart';
import 'package:devsync/features/discover_project/data/model/developer_model.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:devsync/features/discover_project/presentation/screens/discover_home_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/main_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/project_details_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/public_profile_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/search_screen.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_projects/presentation/screens/my_projects_screen.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/screens/my_teams_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_board_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_details_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/task_form_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/team_members_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/team_settings_screen.dart';
import 'package:devsync/features/my_teams/presentation/screens/team_workspace_screen.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
import 'package:devsync/features/profile/presentation/screens/basic_info_screen.dart';
import 'package:devsync/features/profile/presentation/screens/complete_profile_screen.dart';
import 'package:devsync/features/profile/presentation/screens/connect_work_screen.dart';
import 'package:devsync/features/profile/presentation/screens/cv_viewer_screen.dart';
import 'package:devsync/features/profile/presentation/screens/developer_snapshot_screen.dart';
import 'package:devsync/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:devsync/features/profile/presentation/screens/github/analysis_screen.dart';
import 'package:devsync/features/profile/presentation/screens/github/connect_github_screen.dart';
import 'package:devsync/features/profile/presentation/screens/github/review_skills_screen.dart';
import 'package:devsync/features/profile/presentation/screens/project_interests_screen.dart';
import 'package:devsync/features/profile/presentation/screens/skills_expertise_screen.dart';
import 'package:devsync/features/profile/presentation/screens/technical_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return AppPageRoute(builder: (_) => const Splash(), settings: settings);

      case AppRoutes.onBoarding:
        return AppPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case AppRoutes.authEntry:
        return AppPageRoute(
          builder: (_) => const AuthEntryScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return AppPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.createAccount:
        return AppPageRoute(
          builder: (_) => const CreateAccountScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return AppPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.checkInbox:
        final email = settings.arguments is String
            ? settings.arguments as String
            : '';
        return AppPageRoute(
          builder: (_) => CheckInboxScreen(email: email),
          settings: settings,
        );

      case AppRoutes.termsOfService:
        return AppPageRoute(
          builder: (_) => const LegalDocumentScreen(type: LegalDocType.terms),
          settings: settings,
        );

      case AppRoutes.privacyPolicy:
        return AppPageRoute(
          builder: (_) => const LegalDocumentScreen(type: LegalDocType.privacy),
          settings: settings,
        );

      case AppRoutes.main:
        return AppPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );

      case AppRoutes.discoverGuest:
        return AppPageRoute(
          builder: (_) => const DiscoverHomeScreen(),
          settings: settings,
        );

      case AppRoutes.discoverSearch:
        final initialTab = settings.arguments is int
            ? settings.arguments as int
            : 0;
        return AppPageRoute(
          builder: (_) => SearchScreen(initialTab: initialTab),
          settings: settings,
        );

      case AppRoutes.publicProfile:
        final args = settings.arguments;
        if (args is DeveloperModel) {
          return AppPageRoute(
            builder: (_) => PublicProfileScreen(developer: args),
            settings: settings,
          );
        }
        if (args is ({DeveloperModel developer, bool isGuest})) {
          return AppPageRoute(
            builder: (_) => PublicProfileScreen(
              developer: args.developer,
              isGuest: args.isGuest,
            ),
            settings: settings,
          );
        }
        return AppPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Missing profile data'))),
          settings: settings,
        );

      case AppRoutes.projectDetails:
        final args = settings.arguments;
        if (args is ProjectModel) {
          return AppPageRoute(
            builder: (_) => ProjectDetailsScreen(project: args),
            settings: settings,
          );
        }
        return AppPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Missing project data'))),
          settings: settings,
        );

      case AppRoutes.createProject:
        return AppPageRoute(
          builder: (_) =>
              const CreateProjectProviders(child: CreateProjectScreen()),
          settings: settings,
        );

      case AppRoutes.myProjects:
        return AppPageRoute(
          builder: (_) => BlocProvider.value(
            value: ServiceLocator.get<MyProjectsCubit>()..loadData(),
            child: const MyProjectsScreen(),
          ),
          settings: settings,
        );

      // ============== AI Match ===============
      case AppRoutes.matchHistory:
        return AppPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider<MatchCubit>(
                create: (_) => ServiceLocator.get<MatchCubit>()..load(),
              ),
              BlocProvider<ProfileTipCubit>(
                create: (_) => ServiceLocator.get<ProfileTipCubit>()..load(),
              ),
            ],
            child: const MatchHistoryScreen(),
          ),
          settings: settings,
        );

      case AppRoutes.matchWhy:
        return AppPageRoute(
          builder: (_) =>
              WhyThisFitsScreen(match: settings.arguments as MatchModel),
          settings: settings,
        );

      case AppRoutes.skillGap:
        return AppPageRoute(
          builder: (_) =>
              SkillGapScreen(match: settings.arguments as MatchModel),
          settings: settings,
        );

      case AppRoutes.profileEdit:
        return _profileRoute(const EditProfileScreen(), settings);

      case AppRoutes.profileBasicInfo:
        return _profileRoute(const BasicInfoScreen(), settings);

      case AppRoutes.profileTechnical:
        return _profileRoute(const TechnicalProfileScreen(), settings);

      case AppRoutes.profileSkills:
        return _profileRoute(const SkillsExpertiseScreen(), settings);

      case AppRoutes.profileProjects:
        return _profileRoute(const ProjectInterestsScreen(), settings);

      case AppRoutes.profileConnectWork:
        return _profileRoute(const ConnectWorkScreen(), settings);

      case AppRoutes.profileComplete:
        return _profileRoute(const CompleteProfileScreen(), settings);

      case AppRoutes.profileSnapshot:
        return _profileRoute(const DeveloperSnapshotScreen(), settings);

      case AppRoutes.profileGithubConnect:
        return _profileRoute(const ConnectGithubScreen(), settings);

      case AppRoutes.profileGithubAnalysis:
        return _profileRoute(const AnalysisScreen(), settings);

      case AppRoutes.profileGithubReview:
        return _profileRoute(const ReviewSkillsScreen(), settings);

      case AppRoutes.profileCvViewer:
        final args = settings.arguments;
        if (args is ({String title, String? url, Uint8List? bytes})) {
          return AppPageRoute(
            builder: (_) => CvViewerScreen(
              title: args.title,
              url: args.url,
              bytes: args.bytes,
            ),
            settings: settings,
          );
        }
        return AppPageRoute(
          builder: (_) => const CvViewerScreen(title: 'CV'),
          settings: settings,
        );

      case AppRoutes.myTeams:
        return _teamsRoute(const MyTeamsScreen(), settings);

      case AppRoutes.teamWorkspace:
        final args = settings.arguments;
        if (args is Team) {
          return _teamsRoute(TeamWorkspaceScreen(teamId: args.id), settings);
        }
        return _missingArgsRoute('Missing team data', settings);

      case AppRoutes.teamSettings:
        final args = settings.arguments;
        if (args is Team) {
          return _teamsRoute(TeamSettingsScreen(teamId: args.id), settings);
        }
        return _missingArgsRoute('Missing team data', settings);

      case AppRoutes.taskBoard:
        final args = settings.arguments;
        if (args is Team) {
          return _teamsRoute(TaskBoardScreen(teamId: args.id), settings);
        }
        return _missingArgsRoute('Missing team data', settings);

      case AppRoutes.teamMembers:
        final args = settings.arguments;
        if (args is Team) {
          return _teamsRoute(TeamMembersScreen(teamId: args.id), settings);
        }
        return _missingArgsRoute('Missing team data', settings);

      case AppRoutes.taskDetails:
        final args = settings.arguments;
        if (args is TaskItem) {
          return _teamsRoute(TaskDetailsScreen(taskId: args.id), settings);
        }
        return _missingArgsRoute('Missing task data', settings);

      case AppRoutes.taskCreate:
        final args = settings.arguments;
        if (args is Team) {
          return _teamsRoute(TaskFormScreen(teamId: args.id), settings);
        }
        return _missingArgsRoute('Missing team data', settings);

      case AppRoutes.taskEdit:
        final args = settings.arguments;
        if (args is TaskItem) {
          return _teamsRoute(
            TaskFormScreen(teamId: args.teamId, taskId: args.id),
            settings,
          );
        }
        return _missingArgsRoute('Missing task data', settings);

      default:
        return AppPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }

  // ================= My Teams Navigation Helpers =================

  static void toWorkspace(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.teamWorkspace, arguments: team);

  static void toTeamSettings(BuildContext context, Team team) =>
      Navigator.of(context).pushNamed(AppRoutes.teamSettings, arguments: team);

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

  Route _profileRoute(Widget page, RouteSettings settings) {
    return AppPageRoute(
      builder: (_) => ProfileScope(
        controller: ServiceLocator.get<ProfileController>(),
        child: page,
      ),
      settings: settings,
    );
  }

  Route _teamsRoute(Widget page, RouteSettings settings) {
    return AppPageRoute(
      builder: (_) => TeamsScope(
        controller: ServiceLocator.get<TeamsController>(),
        child: page,
      ),
      settings: settings,
    );
  }

  Route _missingArgsRoute(String message, RouteSettings settings) {
    return AppPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
      settings: settings,
    );
  }
}
