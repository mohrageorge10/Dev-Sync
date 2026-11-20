import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/features/auth/presentation/screens/auth_entry_screen.dart';
import 'package:devsync/features/auth/presentation/screens/check_inbox_screen.dart';
import 'package:devsync/features/auth/presentation/screens/create_account_screen.dart';
import 'package:devsync/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:devsync/features/auth/presentation/screens/login_screen.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/screens/create_project_screen.dart';
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
