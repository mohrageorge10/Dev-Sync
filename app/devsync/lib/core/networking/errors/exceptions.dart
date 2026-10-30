import 'package:devsync/core/networking/errors/error_model.dart';
import 'package:dio/dio.dart';

class ServerException implements Exception {
  final ErrorModel errorModel;

  ServerException({required this.errorModel});

  @override
  String toString() => 'ServerException(${errorModel.status}): '
      '${errorModel.errorMsg}';
}

Never handleDioExceptions(DioException e) {
  final statusCode = e.response?.statusCode ?? 0;
  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    throw ServerException(
      errorModel: ErrorModel.fromJson(data, fallbackStatus: statusCode),
    );
  }

  throw ServerException(
    errorModel: ErrorModel(
      status: statusCode,
      errorMsg: switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Connection timed out',
        DioExceptionType.connectionError => 'No internet connection',
        _ => ErrorModel.defaultMessage,
      },
    ),
  );
}
