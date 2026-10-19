import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  SecureStorageHelper._();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static Future<void> saveData({
    required String key,
    required String value,
  }) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getData({
    required String key,
  }) async {
    return _storage.read(key: key);
  }

  static Future<void> removeData({
    required String key,
  }) async {
    await _storage.delete(key: key);
  }

  static Future<bool> containsKey({
    required String key,
  }) async {
    return _storage.containsKey(key: key);
  }

  static Future<void> clearData() async {
    await _storage.deleteAll();
  }
}