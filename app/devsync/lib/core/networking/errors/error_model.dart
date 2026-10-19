import 'package:devsync/core/networking/api/end_points.dart';

class ErrorModel {
  final int status;
  final String errorMsg;

  ErrorModel({required this.status, required this.errorMsg});

  static const String defaultMessage = 'Something went wrong';

  /// Builds the model from a JSON map without ever throwing on missing keys
  /// or unexpected types (e.g. GitHub returns `status` as a String and the
  /// text under `message`, not `ErrorMessage`).
  factory ErrorModel.fromJson(
    Map<String, dynamic> jsonData, {
    int fallbackStatus = 0,
  }) {
    return ErrorModel(
      status: _parseStatus(jsonData[ApiKey.status]) ?? fallbackStatus,
      errorMsg: _parseMessage(jsonData) ?? defaultMessage,
    );
  }

  static int? _parseStatus(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseMessage(Map<String, dynamic> jsonData) {
    for (final key in [ApiKey.errorMsg, ApiKey.msg]) {
      final value = jsonData[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }
}
