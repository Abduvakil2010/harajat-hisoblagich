import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Stores [AppSettings] as a single JSON value.
class SettingsRepository {
  SettingsRepository(this._prefs);

  static const _key = 'hisobai.settings.v1';

  final SharedPreferences _prefs;

  AppSettings load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, Object?>) return AppSettings.fromJson(decoded);
    } on FormatException {
      // Corrupted preferences: fall back to defaults rather than crashing.
    }
    return const AppSettings();
  }

  Future<void> save(AppSettings settings) =>
      _prefs.setString(_key, jsonEncode(settings.toJson()));

  Future<void> clear() => _prefs.remove(_key);
}
