import 'package:devsync/core/animations/app_page_route.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/static/on_boarding/screens/on_boarding.dart';
import 'package:devsync/core/static/splash/Splash.dart';
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
import 'package:flutter/material.dart';

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

      default:
        return AppPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
