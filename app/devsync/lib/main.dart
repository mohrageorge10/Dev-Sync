import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/di/setup_locator.dart';
import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/theme/app_theme.dart';
import 'package:devsync/features/ai_match/di/ai_match_di.dart';
import 'package:devsync/features/auth/di/auth_di.dart';
import 'package:devsync/firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CacheHelper.init();

  setupLocator();
  // Demo: sample projects when the user has no matches yet.
  // Remove `useSampleData` for the real app (empty / error screens).
  setupAiMatchDependencies(useSampleData: true);
  // The "Log in to continue" sheet (Request to Join / Save) opens the login
  // screens, and they need the auth cubit.
  setupAuthDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter().generateRoute,
      // AI Match flow:
      //   Match History -> Why This Fits -> Skill Gap / Rate sheet
      // TODO(team): start from splash / auth / home, and open
      // AppRoutes.matchHistory from a button there.
      initialRoute: AppRoutes.matchHistory,
    );
  }
}
