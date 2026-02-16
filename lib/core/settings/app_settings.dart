import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyArchiveCompleted = 'archive_completed_tasks';
const _keyThemeMode = 'theme_mode';

enum ThemeModePreference { system, light, dark }

/// App-wide settings (e.g. keep done tasks in archive, theme). Persisted via SharedPreferences.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static const _defaultArchiveCompleted = false;
  static const _defaultThemeMode = ThemeModePreference.system;

  bool _archiveCompletedTasks = _defaultArchiveCompleted;
  bool get archiveCompletedTasks => _archiveCompletedTasks;

  ThemeModePreference _themeMode = _defaultThemeMode;
  ThemeModePreference get themeMode => _themeMode;

  static Future<AppSettings> create() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppSettings._();
    s._archiveCompletedTasks = prefs.getBool(_keyArchiveCompleted) ?? _defaultArchiveCompleted;
    final themeStr = prefs.getString(_keyThemeMode);
    s._themeMode = themeStr != null
        ? ThemeModePreference.values.firstWhere(
            (e) => e.name == themeStr,
            orElse: () => _defaultThemeMode,
          )
        : _defaultThemeMode;
    return s;
  }

  Future<void> setArchiveCompletedTasks(bool value) async {
    if (_archiveCompletedTasks == value) return;
    _archiveCompletedTasks = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyArchiveCompleted, value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModePreference value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, value.name);
    notifyListeners();
  }
}
