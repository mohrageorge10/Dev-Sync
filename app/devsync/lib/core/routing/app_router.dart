import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/routing/profile_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Splash")),
          ),
        );

      case AppRoutes.basicInfo:
      case AppRoutes.technical:
      case AppRoutes.skills:
      case AppRoutes.projects:
      case AppRoutes.connectWork:
      case AppRoutes.complete:
      case AppRoutes.snapshot:
      case AppRoutes.explore:
      case AppRoutes.githubConnect:
      case AppRoutes.githubAnalysis:
      case AppRoutes.githubReview:
        return ProfileRouter.generate(settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
