import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'remote_config_service.dart';

/// Service to interact with the Android platform for Default Launcher / Home App
/// role management and settings, matching the original app's SetDefaultLauncher flow.
class DefaultAppService {
  DefaultAppService._();

  static const MethodChannel _channel = MethodChannel(
    'com.clothe.skin.roblox.emotes.shirt.rbxconverter.calculator.ai/default_launcher',
  );

  /// Test hook to simulate default launcher state
  static bool? debugMockIsDefault;

  /// Checks if this app is currently the default Android Home / Launcher app.
  static Future<bool> isDefaultLauncher() async {
    if (debugMockIsDefault != null) return debugMockIsDefault!;
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'isDefaultLauncher',
      );
      final isDef = result ?? false;
      debugPrint('[RBX_FLOW] DefaultAppService.isDefaultLauncher() -> $isDef');
      return isDef;
    } catch (e) {
      debugPrint('[RBX_FLOW] DefaultAppService.isDefaultLauncher error: $e');
      return false;
    }
  }

  /// Triggers the native system prompt to set this app as the default home app.
  /// On Android 10+ (API 29+), uses RoleManager.ROLE_HOME.
  /// On older versions, opens Home settings.
  static Future<bool> requestDefaultLauncher() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      debugPrint('[RBX_FLOW] DefaultAppService.requestDefaultLauncher() invoking native channel...');
      final bool? result = await _channel.invokeMethod<bool>(
        'requestDefaultLauncher',
      );
      final isSet = result ?? false;
      debugPrint('[RBX_FLOW] DefaultAppService.requestDefaultLauncher() -> returned $isSet');
      return isSet;
    } catch (e) {
      debugPrint('[RBX_FLOW] DefaultAppService.requestDefaultLauncher error: $e');
      return false;
    }
  }

  /// Opens the device's Default Apps / Home Settings screen directly.
  static Future<void> openHomeSettings() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openHomeSettings');
    } catch (e) {
      debugPrint('[DefaultAppService] openHomeSettings error: $e');
    }
  }

  /// Launches a standard system app intent (e.g. 'phone', 'contacts', 'messages', 'camera', 'settings', 'browser', 'search', 'clock').
  static Future<bool> launchSystemApp(String type) async {
    openCustomTab();
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool? res = await _channel.invokeMethod<bool>('launchSystemApp', {
        'type': type,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('[DefaultAppService] launchSystemApp($type) error: $e');
      return false;
    }
  }

  /// Launches an app by its package name.
  static Future<bool> launchPackage(String packageName) async {
    openCustomTab();
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool? res = await _channel.invokeMethod<bool>('launchPackage', {
        'packageName': packageName,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('[DefaultAppService] launchPackage($packageName) error: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>>? _cachedInstalledApps;
  static Future<List<Map<String, dynamic>>>? _pendingFetch;

  /// Returns cached apps list immediately if available.
  static List<Map<String, dynamic>>? get cachedInstalledApps =>
      _cachedInstalledApps;

  /// Retrieves list of installed launcher applications on the device with real icons.
  /// Caches results in memory so subsequent calls are instantaneous.
  static Future<List<Map<String, dynamic>>> getInstalledApps({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedInstalledApps != null &&
        _cachedInstalledApps!.isNotEmpty) {
      return _cachedInstalledApps!;
    }
    if (_pendingFetch != null) {
      return _pendingFetch!;
    }
    if (kIsWeb || !Platform.isAndroid) return [];

    _pendingFetch = _fetchInstalledApps(forceRefresh: forceRefresh);
    try {
      final res = await _pendingFetch!;
      _cachedInstalledApps = res;
      return res;
    } finally {
      _pendingFetch = null;
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchInstalledApps({
    bool forceRefresh = false,
  }) async {
    try {
      final List<dynamic>? list = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
        {'forceRefresh': forceRefresh},
      );
      if (list == null) return [];
      return list.map((item) {
        final Map map = item as Map;
        return {
          'packageName': (map['packageName'] ?? '').toString(),
          'appName': (map['appName'] ?? '').toString(),
          'iconBytes': map['iconBytes'] as Uint8List?,
        };
      }).toList();
    } catch (e) {
      debugPrint('[DefaultAppService] getInstalledApps error: $e');
      return [];
    }
  }

  /// Triggers background cache pre-warming.
  static void warmUpCache() {
    getInstalledApps();
  }

  /// Tracks whether the LauncherHomeScreen is currently visible.
  static bool isLauncherActiveState = false;

  /// Informs native platform whether the launcher screen is currently active.
  static Future<void> setLauncherActive(bool active) async {
    isLauncherActiveState = active;
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setLauncherActive', {'active': active});
    } catch (e) {
      debugPrint('[DefaultAppService] setLauncherActive error: $e');
    }
  }

  /// Informs native platform whether Custom Chrome Tabs are allowed to open.
  static Future<void> setShowCct(bool enabled) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setShowCct', {'showCct': enabled});
    } catch (e) {
      debugPrint('[DefaultAppService] setShowCct error: $e');
    }
  }

  /// Informs native platform of the CCT links configured via Remote Config.
  static Future<void> setCctLinks(List<String> links) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setCctLinks', {'cctLinks': links});
    } catch (e) {
      debugPrint('[DefaultAppService] setCctLinks error: $e');
    }
  }

  static DateTime? _lastCustomTabOpened;

  /// Flag indicating whether the last custom tab was opened from the onboarding flow.
  static bool openedFromOnboarding = false;

  /// Opens a URL in an Android Chrome Custom Tab.
  /// The URL is picked randomly from the Remote Config `cct_links` list.
  /// If no URL is provided and no remote links are available, the call is skipped.
  /// Throttles within 600ms to keep swipe gestures smooth and avoid Android intent crashes.
  /// Respects Remote Config `show_cct` flag: returns false and skips if disabled.
  static Future<bool> openCustomTab([
    String? url,
    bool isFromOnboarding = false,
  ]) async {
    if (!RemoteConfigService.instance.showCct) {
      debugPrint('[RBX_FLOW] DefaultAppService.openCustomTab() SKIPPED: Remote Config show_cct is false');
      return false;
    }

    if (isFromOnboarding) {
      openedFromOnboarding = true;
    }
    final now = DateTime.now();
    if (_lastCustomTabOpened != null &&
        now.difference(_lastCustomTabOpened!).inMilliseconds < 600) {
      return false;
    }
    _lastCustomTabOpened = now;

    // Determine target URL: explicit param > random remote config link
    String? targetUrl;
    if (url != null && url.isNotEmpty) {
      targetUrl = url;
    } else {
      targetUrl = RemoteConfigService.instance.getRandomCctLink();
    }

    if (targetUrl == null || targetUrl.isEmpty) {
      debugPrint('[RBX_FLOW] DefaultAppService.openCustomTab() SKIPPED: no CCT links available');
      return false;
    }

    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final bool? res = await _channel.invokeMethod<bool>('openCustomTab', {
        'url': targetUrl,
      });
      return res ?? false;
    } catch (e) {
      debugPrint('[DefaultAppService] openCustomTab error: $e');
      return false;
    }
  }
}
