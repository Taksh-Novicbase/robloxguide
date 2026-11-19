import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import 'default_app_service.dart';

/// Service managing Firebase Remote Config parameters for the application.
///
/// Specifically governs:
/// - `show_ad`: Remote boolean toggle controlling all ads (Interstitials, AppOpen, Rewarded, Banners, Native).
/// - `show_cct`: Remote boolean toggle controlling Android Chrome Custom Tabs opening.
/// - `ads_id`: Remote JSON string parameter containing dynamic production AdMob App & Unit IDs.
/// - `cct_links`: Remote JSON string parameter containing CCT restaurant link URLs.
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  static const String keyShowAd = 'show_ad';
  static const String keyShowCct = 'show_cct';
  static const String keyAdsId = 'ads_id';
  static const String keyCctLinks = 'cct_links';

  static const String _prefCachedShowAd = 'rc_cached_show_ad';
  static const String _prefCachedShowCct = 'rc_cached_show_cct';
  static const String _prefCachedAdsId = 'rc_cached_ads_id';
  static const String _prefCachedCctLinks = 'rc_cached_cct_links';

  bool _showAd = true;
  bool _showCct = true;
  bool _initialized = false;
  Map<String, String> _remoteAdIds = {};

  /// CCT restaurant links fetched from Remote Config.
  List<String> _cctLinks = [];
  final Random _random = Random();

  /// Test hook overrides
  bool? debugOverrideShowAd;
  bool? debugOverrideShowCct;
  Map<String, String>? debugOverrideRemoteAdIds;
  List<String>? debugOverrideCctLinks;

  /// Whether ads should be loaded and displayed throughout the app.
  bool get showAd => debugOverrideShowAd ?? _showAd;

  /// Whether Chrome Custom Tabs should be opened upon user interactions/navigation.
  bool get showCct => debugOverrideShowCct ?? _showCct;

  /// Parsed Ad IDs fetched from Remote Config `ads_id`.
  Map<String, String> get remoteAdIds =>
      debugOverrideRemoteAdIds ?? Map.unmodifiable(_remoteAdIds);

  /// Whether any custom remote Ad IDs have been loaded.
  bool get hasRemoteAdIds =>
      (debugOverrideRemoteAdIds?.isNotEmpty ?? false) ||
      _remoteAdIds.isNotEmpty;

  /// Returns all CCT links fetched from Remote Config.
  List<String> get cctLinks =>
      debugOverrideCctLinks ?? List.unmodifiable(_cctLinks);

  /// Returns a random CCT link from the remote config list, or null if empty.
  String? getRandomCctLink() {
    final links = debugOverrideCctLinks ?? _cctLinks;
    if (links.isEmpty) return null;
    return links[_random.nextInt(links.length)];
  }

  /// Exposed for testing JSON formats of cct_links.
  @visibleForTesting
  void parseCctLinksJsonForTesting(String rawJson) {
    _parseCctLinksJson(rawJson);
  }

  bool get isInitialized => _initialized;

  StreamSubscription<RemoteConfigUpdate>? _configSubscription;

  /// Initializes Remote Config:
  /// 1. Reads fast cached values from SharedPreferences to avoid UI delays.
  /// 2. Sets up Firebase Remote Config defaults and fetch settings.
  /// 3. Fetches live values and activates them.
  /// 4. Subscribes to real-time Remote Config updates.
  Future<void> init() async {
    if (_initialized) return;

    // Step 1: Read locally cached values from SharedPreferences immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      _showAd = prefs.getBool(_prefCachedShowAd) ?? true;
      _showCct = prefs.getBool(_prefCachedShowCct) ?? true;

      final cachedAdsIdJson = prefs.getString(_prefCachedAdsId);
      if (cachedAdsIdJson != null && cachedAdsIdJson.isNotEmpty) {
        _parseAdsJson(cachedAdsIdJson);
      }

      final cachedCctLinksJson = prefs.getString(_prefCachedCctLinks);
      if (cachedCctLinksJson != null && cachedCctLinksJson.isNotEmpty) {
        _parseCctLinksJson(cachedCctLinksJson);
      }

      debugPrint(
        '[RemoteConfig] Cached values loaded: show_ad=$_showAd, show_cct=$_showCct, adsLoaded=${_remoteAdIds.length}, cctLinks=${_cctLinks.length}',
      );

      // Sync initial show_cct state and cct_links with Android platform
      await DefaultAppService.setShowCct(showCct);
      if (_cctLinks.isNotEmpty) {
        await DefaultAppService.setCctLinks(_cctLinks);
      }
    } catch (e) {
      debugPrint('[RemoteConfig] Error reading cached config: $e');
    }

    // Step 2: Initialize Firebase and Remote Config
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint(
          '[RemoteConfig] Initializing Firebase with DefaultFirebaseOptions...',
        );
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );

      // Set fallback defaults in Firebase Remote Config
      await remoteConfig.setDefaults({
        keyShowAd: true,
        keyShowCct: true,
        keyAdsId: '',
        keyCctLinks: '',
      });

      // Fetch and activate latest values
      final activated = await remoteConfig.fetchAndActivate();
      debugPrint('[RemoteConfig] fetchAndActivate() result: $activated');

      await _applyRemoteValues(remoteConfig);

      // Step 3: Listen for live real-time config updates
      _configSubscription?.cancel();
      _configSubscription = remoteConfig.onConfigUpdated.listen((event) async {
        debugPrint(
          '[RemoteConfig] Real-time config update detected: ${event.updatedKeys}',
        );
        try {
          await remoteConfig.activate();
          await _applyRemoteValues(remoteConfig);
        } catch (e) {
          debugPrint('[RemoteConfig] Error activating real-time update: $e');
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint(
        '[RemoteConfig] Firebase Remote Config init/fetch failed (falling back to cache/defaults): $e',
      );
      _initialized = true;
    }
  }

  Future<void> _applyRemoteValues(FirebaseRemoteConfig remoteConfig) async {
    _showAd = remoteConfig.getBool(keyShowAd);
    _showCct = remoteConfig.getBool(keyShowCct);
    final rawAdsIdJson = remoteConfig.getString(keyAdsId);
    final rawCctLinksJson = remoteConfig.getString(keyCctLinks);

    if (rawAdsIdJson.trim().isNotEmpty) {
      _parseAdsJson(rawAdsIdJson);
    }

    if (rawCctLinksJson.trim().isNotEmpty) {
      _parseCctLinksJson(rawCctLinksJson);
    }

    debugPrint(
      '[RemoteConfig] Live config applied: show_ad=$_showAd, show_cct=$_showCct, remoteAdUnits=${_remoteAdIds.length}, cctLinks=${_cctLinks.length}',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefCachedShowAd, _showAd);
      await prefs.setBool(_prefCachedShowCct, _showCct);
      if (rawAdsIdJson.trim().isNotEmpty) {
        await prefs.setString(_prefCachedAdsId, rawAdsIdJson);
      }
      if (rawCctLinksJson.trim().isNotEmpty) {
        await prefs.setString(_prefCachedCctLinks, rawCctLinksJson);
      }
    } catch (e) {
      debugPrint('[RemoteConfig] Error persisting cached config: $e');
    }

    // Inform native Android of the live show_cct setting and cct_links
    await DefaultAppService.setShowCct(showCct);
    if (_cctLinks.isNotEmpty) {
      await DefaultAppService.setCctLinks(_cctLinks);
    }
  }

  /// Parses raw JSON string from `ads_id` parameter into memory.
  /// Supports both flat key-value formats and nested flow structures.
  void _parseAdsJson(String rawJson) {
    if (rawJson.trim().isEmpty) return;
    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is Map) {
        final Map<String, String> parsed = {};
        _extractMapEntries(decoded, parsed, '');
        _remoteAdIds = parsed;
        debugPrint(
          '[RemoteConfig] ads_id JSON parsed successfully: ${_remoteAdIds.length} ad unit keys loaded',
        );
      }
    } catch (e) {
      debugPrint('[RemoteConfig] Failed to parse ads_id JSON: $e');
    }
  }

  /// Parses raw JSON string from `cct_links` parameter into memory.
  /// Expects: `{"links": ["url1", "url2", ...]}`
  void _parseCctLinksJson(String rawJson) {
    if (rawJson.trim().isEmpty) return;
    try {
      final dynamic decoded = jsonDecode(rawJson);
      List<dynamic>? rawList;
      if (decoded is Map && decoded['links'] is List) {
        rawList = decoded['links'] as List;
      } else if (decoded is List) {
        rawList = decoded;
      }

      if (rawList != null) {
        _cctLinks = rawList
            .whereType<String>()
            .map((e) => e.trim())
            .where((url) =>
                url.isNotEmpty &&
                (url.startsWith('http://') || url.startsWith('https://')))
            .toList();
        debugPrint(
            '[RemoteConfig] cct_links parsed successfully: ${_cctLinks.length} links loaded');
      }
    } catch (e) {
      debugPrint('[RemoteConfig] Failed to parse cct_links JSON: $e');
    }
  }

  void _extractMapEntries(Map map, Map<String, String> result, String prefix) {
    map.forEach((key, value) {
      final keyStr = key.toString();
      if (value is String) {
        result[keyStr] = value;
        if (prefix.isNotEmpty) {
          result['$prefix$keyStr'] = value;
          result['${prefix}_$keyStr'] = value;
        }
      } else if (value is Map) {
        _extractMapEntries(value, result, keyStr);
      }
    });
  }

  /// Retrieves an ad unit ID from the remote config `ads_id` JSON.
  /// Matches flexibly against exact key, stripped 'prod' key, snake_case, or lowercase.
  /// Falls back to [fallbackId] if not configured in remote config.
  String getAdUnitId(String key, String fallbackId) {
    final activeIds = debugOverrideRemoteAdIds ?? _remoteAdIds;
    if (activeIds.isEmpty) return fallbackId;

    // 1. Direct exact match
    if (activeIds.containsKey(key) && (activeIds[key]?.isNotEmpty ?? false)) {
      return activeIds[key]!;
    }

    // 2. Stripped 'prod' prefix match: prodSplashAppOpenId -> splashAppOpenId
    if (key.startsWith('prod') && key.length > 4) {
      final stripped = key.substring(4);
      final camel = '${stripped[0].toLowerCase()}${stripped.substring(1)}';
      if (activeIds.containsKey(camel) &&
          (activeIds[camel]?.isNotEmpty ?? false)) {
        return activeIds[camel]!;
      }
    }

    // 3. Snake case match: prodSplashAppOpenId -> prod_splash_app_open_id & splash_app_open_id
    final snake = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => '_${m.group(1)!.toLowerCase()}',
    );
    if (activeIds.containsKey(snake) &&
        (activeIds[snake]?.isNotEmpty ?? false)) {
      return activeIds[snake]!;
    }
    final strippedSnake = snake.startsWith('_prod_')
        ? snake.substring(6)
        : (snake.startsWith('prod_') ? snake.substring(5) : snake);
    if (activeIds.containsKey(strippedSnake) &&
        (activeIds[strippedSnake]?.isNotEmpty ?? false)) {
      return activeIds[strippedSnake]!;
    }

    // 4. Case-insensitive lookup
    final lowerKey = key.toLowerCase();
    for (final entry in activeIds.entries) {
      if (entry.key.toLowerCase() == lowerKey && entry.value.isNotEmpty) {
        return entry.value;
      }
    }

    return fallbackId;
  }

  /// Disposes stream subscriptions
  void dispose() {
    _configSubscription?.cancel();
  }
}
