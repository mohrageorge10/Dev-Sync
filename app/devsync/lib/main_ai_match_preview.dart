import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_theme.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_feedback_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_cubit.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/data/repos/profile_tip_repo.dart';
import 'package:flutter/material.dart';

/// Preview of the whole AI Match flow with sample data
/// (no Firebase, no .env, nothing is saved):
///   Match History -> Why This Project Fits You -> Skill Gap / Rate sheet
///
///   flutter run -d chrome -t lib/main_ai_match_preview.dart
void main() {
  ServiceLocator.registerLazySingleton<MatchRepo>(() => MockMatchRepo());
  ServiceLocator.registerFactory<MatchCubit>(
    () => MatchCubit(ServiceLocator.get<MatchRepo>()),
  );
  ServiceLocator.registerFactory<MatchFeedbackCubit>(
    () => MatchFeedbackCubit(ServiceLocator.get<MatchRepo>()),
  );
  ServiceLocator.registerFactory<MatchActionsCubit>(
    () => MatchActionsCubit(ServiceLocator.get<MatchRepo>()),
  );
  ServiceLocator.registerFactory<ProfileTipCubit>(
    () => ProfileTipCubit(MockProfileTipRepo()),
  );
  runApp(const _AiMatchPreviewApp());
}

class _AiMatchPreviewApp extends StatelessWidget {
  const _AiMatchPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // ThemeMode.dark to test dark
      onGenerateRoute: AppRouter().generateRoute,
      initialRoute: AppRoutes.matchHistory,
    );
  }
}