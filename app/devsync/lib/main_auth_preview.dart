import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/di/setup_locator.dart';
import 'package:devsync/core/theme/app_theme.dart';
import 'package:devsync/features/auth/di/auth_di.dart';
import 'package:devsync/features/auth/screens/auth_entry_screen.dart';
import 'package:devsync/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Opens the auth flow directly (skips the splash), with the real setup:
///   flutter run -t lib/main_auth_preview.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CacheHelper.init();
  setupLocator();
  setupAuthDependencies();
  runApp(const AuthPreviewApp());
}

class AuthPreviewApp extends StatelessWidget {
  const AuthPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevSync (auth preview)',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const AuthEntryScreen(),
    );
  }
}
