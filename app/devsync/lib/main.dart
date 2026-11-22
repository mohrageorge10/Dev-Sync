import 'package:devsync/app_bootstrap.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await bootstrap();
  runApp(const DevSyncApp(initialRoute: AppRoutes.splash));
}
