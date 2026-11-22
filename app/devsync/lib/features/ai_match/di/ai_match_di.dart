import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_feedback_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/profile_tip_cubit.dart';
import 'package:devsync/features/ai_match/data/repos/match_repo.dart';
import 'package:devsync/features/ai_match/data/repos/profile_tip_repo.dart';

/// Registers the AI Match feature. Call it once, right after `setupLocator()`.
///
/// [useSampleData] = true shows sample projects when the user has no matches
/// yet (good for demos). Keep false for the real app.
void setupAiMatchDependencies({bool useSampleData = false}) {
  if (ServiceLocator.isRegistered<MatchRepo>()) return;

  ServiceLocator.registerLazySingleton<MatchRepo>(
    () => FirestoreMatchRepo(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
      sampleDataFallback: useSampleData,
    ),
  );

  ServiceLocator.registerLazySingleton<ProfileTipRepo>(
    () => FirestoreProfileTipRepo(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
    ),
  );

  // Factories: every screen / sheet gets its own Cubit.
  // The cubits reload their data when the user logs in or out.
  ServiceLocator.registerFactory<MatchCubit>(
    () => MatchCubit(
      ServiceLocator.get<MatchRepo>(),
      userIdChanges: _userIdChanges(),
    ),
  );
  ServiceLocator.registerFactory<ProfileTipCubit>(
    () => ProfileTipCubit(
      ServiceLocator.get<ProfileTipRepo>(),
      userIdChanges: _userIdChanges(),
    ),
  );
  ServiceLocator.registerFactory<MatchFeedbackCubit>(
    () => MatchFeedbackCubit(ServiceLocator.get<MatchRepo>()),
  );
  ServiceLocator.registerFactory<MatchActionsCubit>(
    () => MatchActionsCubit(
      ServiceLocator.get<MatchRepo>(),
      userIdChanges: _userIdChanges(),
    ),
  );
}

/// uid of the signed-in user (null = signed out), every time it changes.
Stream<String?> _userIdChanges() => ServiceLocator.get<FirebaseAuthService>()
    .authStateChanges
    .map((user) => user?.uid);
