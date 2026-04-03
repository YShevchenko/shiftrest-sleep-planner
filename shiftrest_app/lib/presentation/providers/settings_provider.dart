import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state management.
class SettingsProvider extends ChangeNotifier {
  static const _keyCommuteMinutes = 'commute_minutes';
  static const _keyPrepMinutes = 'prep_minutes';
  static const _keyUse24HourFormat = 'use_24_hour_format';
  static const _keyDefaultShiftType = 'default_shift_type';
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyLocale = 'locale';
  static const _keyHealthSync = 'shiftrest_health_sync';

  int _commuteMinutes = 30;
  int _prepMinutes = 30;
  bool _use24HourFormat = true;
  String _defaultShiftType = 'night';
  bool _onboardingComplete = false;
  String _locale = 'en';
  bool _healthSync = false;

  int get commuteMinutes => _commuteMinutes;
  int get prepMinutes => _prepMinutes;
  bool get use24HourFormat => _use24HourFormat;
  String get defaultShiftType => _defaultShiftType;
  bool get onboardingComplete => _onboardingComplete;
  String get locale => _locale;
  bool get healthSync => _healthSync;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _commuteMinutes = prefs.getInt(_keyCommuteMinutes) ?? 30;
    _prepMinutes = prefs.getInt(_keyPrepMinutes) ?? 30;
    _use24HourFormat = prefs.getBool(_keyUse24HourFormat) ?? true;
    _defaultShiftType = prefs.getString(_keyDefaultShiftType) ?? 'night';
    _onboardingComplete = prefs.getBool(_keyOnboardingComplete) ?? false;
    _locale = prefs.getString(_keyLocale) ?? 'en';
    _healthSync = prefs.getBool(_keyHealthSync) ?? false;
    notifyListeners();
  }

  Future<void> setCommuteMinutes(int minutes) async {
    _commuteMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCommuteMinutes, minutes);
    notifyListeners();
  }

  Future<void> setPrepMinutes(int minutes) async {
    _prepMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPrepMinutes, minutes);
    notifyListeners();
  }

  Future<void> setUse24HourFormat(bool value) async {
    _use24HourFormat = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUse24HourFormat, value);
    notifyListeners();
  }

  Future<void> setDefaultShiftType(String type) async {
    _defaultShiftType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultShiftType, type);
    notifyListeners();
  }

  Future<void> setOnboardingComplete(bool value) async {
    _onboardingComplete = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, value);
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    notifyListeners();
  }

  Future<void> setHealthSync(bool value) async {
    _healthSync = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHealthSync, value);
    notifyListeners();
  }
}
