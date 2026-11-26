import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/di/setup_locator.dart';
import 'package:devsync/core/routing/app_router.dart';
import 'package:devsync/core/theme/app_theme.dart';
import 'package:devsync/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CacheHelper.init();

  setupLocator();
}

class DevSyncApp extends StatelessWidget {
  const DevSyncApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter().generateRoute,
    );
  }
}
