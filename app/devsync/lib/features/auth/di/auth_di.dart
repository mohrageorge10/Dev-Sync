import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/auth/business_logic/auth_cubit.dart';
import 'package:devsync/features/auth/data/repos/auth_repo.dart';

/// Registers the auth feature. Call it once, right after `setupLocator()`.
void setupAuthDependencies() {
  if (ServiceLocator.isRegistered<AuthRepo>()) return;

  ServiceLocator.registerLazySingleton<AuthRepo>(
    () => AuthRepo(
      authService: ServiceLocator.get<FirebaseAuthService>(),
      firestoreService: ServiceLocator.get<FirestoreService>(),
    ),
  );

  // Factory: every screen gets its own Cubit (and disposes it).
  ServiceLocator.registerFactory<AuthCubit>(
    () => AuthCubit(ServiceLocator.get<AuthRepo>()),
  );
}
