import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/networking/api/api_consumer.dart';
import 'package:devsync/core/networking/api/dio_consumer.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/auth/data/repositories/auth_repository.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';
import 'package:devsync/features/create_project/data/repositories/project_repository.dart';
import 'package:devsync/features/discover_project/data/repositories/discover_repository.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:dio/dio.dart';

void setupLocator() {
  // Guard against double registration (e.g. hot restart in tests).
  if (ServiceLocator.isRegistered<Dio>()) return;

  // Networking
  ServiceLocator.registerLazySingleton<Dio>(() => Dio());
  ServiceLocator.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(dio: ServiceLocator.get<Dio>()),
  );

  // Firebase services
  ServiceLocator.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );
  ServiceLocator.registerLazySingleton<FirestoreService>(
    () => FirestoreService(),
  );

  // Auth Repository & Cubit
  ServiceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: ServiceLocator.get<FirebaseAuthService>(),
      firestoreService: ServiceLocator.get<FirestoreService>(),
    ),
  );
  ServiceLocator.registerFactory<AuthCubit>(
    () => AuthCubit(ServiceLocator.get<AuthRepository>()),
  );

  // Create Project Repositories
  ServiceLocator.registerLazySingleton<BuildersRepository>(
    () => FirestoreBuildersRepository(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
    ),
  );
  ServiceLocator.registerLazySingleton<ProjectRepository>(
    () => FirestoreProjectRepository(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
      buildersRepository: ServiceLocator.get<BuildersRepository>(),
    ),
  );

  // Discover Repository & Shared Cubit
  ServiceLocator.registerLazySingleton<DiscoverRepository>(
    () => DiscoverRepository(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
    ),
  );
  ServiceLocator.registerLazySingleton<DiscoverCubit>(
    () => DiscoverCubit(repository: ServiceLocator.get<DiscoverRepository>()),
  );
}
