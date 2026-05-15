import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // --- String ---
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  // --- Bool ---
  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  // --- Remove ---
  Future<bool> remove(String key) => _prefs.remove(key);

  // --- Clear all (used on logout) ---
  Future<bool> clear() => _prefs.clear();
}
