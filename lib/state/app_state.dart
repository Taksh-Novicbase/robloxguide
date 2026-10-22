import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide mutable state (Robux balance + onboarding flag), persisted with
/// shared_preferences — mirroring the original `SharedPreferences("PrefName")`
/// usage with the `RobCoins` key.
class AppState extends ChangeNotifier {
  static const String _robuxKey = 'RobCoins';
  static const String _onboardingKey = 'onboarding_done';
  static const String _defaultAppPromptedKey = 'default_app_prompted';
  static const String _settingLauncherKey = 'setting_launcher_in_progress';

  int robux = 0;
  bool onboardingDone = false;
  bool defaultAppPrompted = false;
  bool settingLauncherInProgress = false;
  bool _initialized = false;

  AppState() {
    _load();
  }

  Future<void> init() async {
    if (_initialized) return;
    await _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      robux = prefs.getInt(_robuxKey) ?? 0;
      onboardingDone = prefs.getBool(_onboardingKey) ?? false;
      defaultAppPrompted = prefs.getBool(_defaultAppPromptedKey) ?? false;
      settingLauncherInProgress = prefs.getBool(_settingLauncherKey) ?? false;
    } catch (_) {
      // Keep defaults if storage is unavailable.
    }
    _initialized = true;
    notifyListeners();
  }

  bool get initialized => _initialized;

  Future<void> setRobux(int amount) async {
    robux = amount < 0 ? 0 : amount;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_robuxKey, robux);
    } catch (_) {}
  }

  Future<void> addRobux(int amount) async {
    await setRobux(robux + amount);
  }

  Future<void> setDefaultAppPrompted(bool value) async {
    defaultAppPrompted = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_defaultAppPromptedKey, value);
    } catch (_) {}
  }

  Future<void> completeOnboarding() async {
    onboardingDone = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {}
  }

  Future<void> setSettingLauncherInProgress(bool value) async {
    settingLauncherInProgress = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_settingLauncherKey, value);
    } catch (_) {}
  }

  Future<void> resetOnboarding() async {
    onboardingDone = false;
    defaultAppPrompted = false;
    settingLauncherInProgress = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
      await prefs.setBool(_defaultAppPromptedKey, false);
      await prefs.setBool(_settingLauncherKey, false);
    } catch (_) {}
  }
}
