import 'dart:async';

import 'package:get_it/get_it.dart';

class ServiceLocator {
  ServiceLocator._();

  static final GetIt _getIt = GetIt.instance;

  // ================= Register =================

  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool? signalsReady,
    FutureOr Function(T)? dispose,
  }) {
    _getIt.registerSingleton<T>(
      instance,
      instanceName: instanceName,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }

  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
    FutureOr Function(T)? dispose,
  }) {
    _getIt.registerLazySingleton<T>(
      factory,
      instanceName: instanceName,
      dispose: dispose,
    );
  }

  static void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factory, instanceName: instanceName);
  }

  static void registerFactoryParam<T extends Object, P1, P2>(
    T Function(P1 param1, P2 param2) factory, {
    String? instanceName,
  }) {
    _getIt.registerFactoryParam<T, P1, P2>(
      factory,
      instanceName: instanceName,
    );
  }

  static void registerSingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    String? instanceName,
    Iterable<Type>? dependsOn,
    bool? signalsReady,
    FutureOr Function(T)? dispose,
  }) {
    _getIt.registerSingletonAsync<T>(
      factory,
      instanceName: instanceName,
      dependsOn: dependsOn,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }

  static void registerLazySingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    String? instanceName,
    FutureOr Function(T)? dispose,
  }) {
    _getIt.registerLazySingletonAsync<T>(
      factory,
      instanceName: instanceName,
      dispose: dispose,
    );
  }

  // ================= Get =================

  static T get<T extends Object>({
    dynamic param1,
    dynamic param2,
    String? instanceName,
  }) {
    return _getIt.get<T>(
      param1: param1,
      param2: param2,
      instanceName: instanceName,
    );
  }

  static Future<T> getAsync<T extends Object>({
    dynamic param1,
    dynamic param2,
    String? instanceName,
  }) {
    return _getIt.getAsync<T>(
      param1: param1,
      param2: param2,
      instanceName: instanceName,
    );
  }

  // ================= Check / Wait =================

  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }

  static Future<void> allReady({Duration? timeout}) {
    return _getIt.allReady(timeout: timeout);
  }

  // ================= Remove / Reset =================

  static Future<void> unregister<T extends Object>({
    String? instanceName,
  }) async {
    await _getIt.unregister<T>(instanceName: instanceName);
  }

  static Future<void> resetLazySingleton<T extends Object>({
    String? instanceName,
  }) async {
    await _getIt.resetLazySingleton<T>(instanceName: instanceName);
  }

  static Future<void> reset({bool dispose = true}) async {
    await _getIt.reset(dispose: dispose);
  }

  // ================= Scopes =================

  static void pushNewScope({
    required String scopeName,
    void Function(GetIt getIt)? init,
  }) {
    _getIt.pushNewScope(scopeName: scopeName, init: init);
  }

  static Future<void> popScope() async {
    await _getIt.popScope();
  }

  static Future<void> dropScope(String scopeName) async {
    await _getIt.dropScope(scopeName);
  }
}