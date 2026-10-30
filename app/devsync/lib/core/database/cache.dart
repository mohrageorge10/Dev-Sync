import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  CacheHelper._();

  static late SharedPreferences _preferences;
  static bool _isInitialized = false;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  static void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'CacheHelper.init() must be called before using CacheHelper.',
      );
    }
  }

  static Future<bool> saveData({
    required String key,
    required Object value,
  }) async {
    _checkInitialized();

    if (value is String) {
      return _preferences.setString(key, value);
    } else if (value is bool) {
      return _preferences.setBool(key, value);
    } else if (value is int) {
      return _preferences.setInt(key, value);
    } else if (value is double) {
      return _preferences.setDouble(key, value);
    } else if (value is List<String>) {
      return _preferences.setStringList(key, value);
    }

    throw ArgumentError('Unsupported value type: ${value.runtimeType}');
  }

  static String? getDataString({required String key}) {
    _checkInitialized();
    return _preferences.getString(key);
  }

  static T? getData<T>({required String key}) {
    _checkInitialized();

    final Object? value = _preferences.get(key);

    if (value == null) return null;

    if (value is T) return value as T;

    throw StateError('Stored value for "$key" is not of type $T.');
  }

  static bool containsKey({required String key}) {
    _checkInitialized();
    return _preferences.containsKey(key);
  }

  static Future<bool> removeData({required String key}) async {
    _checkInitialized();
    return _preferences.remove(key);
  }

  static Future<bool> clearData() async {
    _checkInitialized();
    return _preferences.clear();
  }
}
