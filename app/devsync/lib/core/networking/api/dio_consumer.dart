import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/networking/api/api_consumer.dart';
import 'package:devsync/core/networking/api/end_points.dart';
import 'package:devsync/core/networking/errors/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options
      ..baseUrl = EndPoint.baseUrl
      ..connectTimeout = const Duration(seconds: AppConstants.apiTimeout)
      ..receiveTimeout = const Duration(seconds: AppConstants.apiTimeout)
      ..sendTimeout = const Duration(seconds: AppConstants.apiTimeout);

    // Logs requests/responses (including headers & tokens) -> debug only.
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          error: true,
        ),
      );
    }
  }

  /// Converts [data] to [FormData] only when asked, and only if it is a map.
  /// A null body is passed through untouched instead of crashing.
  Object? _prepareBody(Object? data, bool isFormData) {
    if (!isFormData || data == null) return data;
    if (data is FormData) return data;
    if (data is Map<String, dynamic>) return FormData.fromMap(data);
    throw ArgumentError(
      'isFormData requires a Map<String, dynamic> or FormData, '
      'got ${data.runtimeType}.',
    );
  }

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: _prepareBody(data, isFormData),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: _prepareBody(data, isFormData),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: _prepareBody(data, isFormData),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }
}
