import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/features/ai_match/business_logic/match_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_cubit.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/screens/match_history_screen.dart';
import 'package:devsync/features/ai_match/screens/skill_gap_screen.dart';
import 'package:devsync/features/ai_match/screens/why_this_fits_screen.dart';
import 'package:devsync/features/create_project/presentation/cubit/create_project_providers.dart';
import 'package:devsync/features/create_project/presentation/screens/create_project_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

      // ============== AI Match ===============
      case AppRoutes.matchHistory:
        return MaterialPageRoute(
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
        return MaterialPageRoute(
          builder: (_) =>
              WhyThisFitsScreen(match: settings.arguments as MatchModel),
          settings: settings,
        );

      case AppRoutes.skillGap:
        return MaterialPageRoute(
          builder: (_) =>
              SkillGapScreen(match: settings.arguments as MatchModel),
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
