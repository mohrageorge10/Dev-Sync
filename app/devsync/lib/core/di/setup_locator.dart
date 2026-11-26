import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/networking/api/api_consumer.dart';
import 'package:devsync/core/networking/api/dio_consumer.dart';
import 'package:devsync/core/services/cloudinary/cloudinary_service.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/features/ai_match/di/ai_match_di.dart';
import 'package:devsync/features/auth/data/repositories/auth_repository.dart';
import 'package:devsync/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';
import 'package:devsync/features/create_project/data/repositories/project_repository.dart';
import 'package:devsync/features/discover_project/data/repositories/discover_repository.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/my_projects/data/repo/my_projects_repo.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/data/repositories/teams_repository.dart';
import 'package:devsync/features/profile/data/repositories/profile_repository.dart';
import 'package:devsync/features/profile/presentation/cubit/profile_controller.dart';
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

  // Cloudinary media service
  ServiceLocator.registerLazySingleton<CloudinaryService>(
    () => CloudinaryService(dio: ServiceLocator.get<Dio>()),
  );

  // Profile Repository & Shared Controller
  ServiceLocator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
      cloudinaryService: ServiceLocator.get<CloudinaryService>(),
    ),
  );
  ServiceLocator.registerLazySingleton<ProfileController>(
    () => ProfileController(repository: ServiceLocator.get<ProfileRepository>()),
  );

  // My Teams Repository & Shared Controller
  ServiceLocator.registerLazySingleton<TeamsRepository>(
    () => TeamsRepository(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
    ),
  );
  ServiceLocator.registerLazySingleton<TeamsController>(
    () => TeamsController(repository: ServiceLocator.get<TeamsRepository>()),
  );

  // My Projects Repository & Shared Cubit
  ServiceLocator.registerLazySingleton<MyProjectsRepo>(
    () => MyProjectsRepo(
      firestoreService: ServiceLocator.get<FirestoreService>(),
      authService: ServiceLocator.get<FirebaseAuthService>(),
    ),
  );
  ServiceLocator.registerLazySingleton<MyProjectsCubit>(
    () => MyProjectsCubit(ServiceLocator.get<MyProjectsRepo>()),
  );

  // AI Match Repositories & Cubits
  setupAiMatchDependencies(useSampleData: true);
}
