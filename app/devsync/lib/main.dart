import 'package:devsync/app_bootstrap.dart';
import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrap();
  final isSignedIn = ServiceLocator.get<FirebaseAuthService>().isSignedIn;
  runApp(
    DevSyncApp(
      initialRoute: isSignedIn ? AppRoutes.main : AppRoutes.authEntry,
    ),
  );
}
