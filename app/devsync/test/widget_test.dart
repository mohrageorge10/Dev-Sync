import 'package:devsync/app_bootstrap.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds without crashing', (tester) async {
    await tester.pumpWidget(
      const DevSyncApp(initialRoute: AppRoutes.discoverGuest),
    );

    expect(find.byType(DevSyncApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
