import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/networking/api/api_consumer.dart';
import 'package:devsync/core/networking/api/dio_consumer.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
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
}
