import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/theme/app_theme.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/business_logic/match_feedback_cubit.dart';
import 'package:devsync/features/ai_match/data/models/match_feedback.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/widgets/rate_recommendation_sheet.dart';
import 'package:flutter/material.dart';

/// Preview of the "Rate Recommendation" sheet only (no Firebase, no .env):
///   flutter run -d chrome -t lib/main_rate_sheet_preview.dart
void main() {
  ServiceLocator.registerFactory<MatchFeedbackCubit>(
    () => MatchFeedbackCubit(_FakeMatchRepo()),
  );
  runApp(const _PreviewApp());
}

class _FakeMatchRepo implements MatchRepo {
  @override
  Future<List<MatchModel>> getMatches() async => const [];

  @override
  Future<void> submitFeedback(MatchFeedback feedback) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<bool> isSaved(String projectId) async => false;

  @override
  Future<void> setSaved(MatchModel match, bool saved) async {}

  @override
  Future<RequestStatus?> getJoinRequestStatus(String projectId) async => null;

  @override
  Future<void> requestToJoin(MatchModel match, {String pitch = ''}) async {}
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light, // change to ThemeMode.dark to test dark
      home: const _PreviewScreen(),
    );
  }
}

class _PreviewScreen extends StatelessWidget {
  const _PreviewScreen();

  static const _match = MatchModel(
    projectId: 'preview',
    projectTitle: 'Preview Project',
    score: 85,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showRateRecommendationSheet(
            context,
            match: _match,
            initialHelpful: false,
          ),
          child: const Text('Open Rate Sheet'),
        ),
      ),
    );
  }
}