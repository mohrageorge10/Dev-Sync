import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/screens/create_project_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text("Splash"))),
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
