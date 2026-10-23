import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_ids.dart';

/// Comprehensive Ad Manager for Roblox Skins Tool.
///
/// Implements precaching, preloading, and lifecycle management for all AdMob formats:
/// - App Open Ad (cold start & foreground resume)
/// - Interstitial Ads (precached with automatic background re-loading upon dismissal)
/// - Banner Ads (adaptive & standard)
/// - Native Ads
///
/// Closely replicates the behavior of `Lbm/q;` from the reference APK.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Precached Interstitial Ads (keyed by ad unit ID)
  final Map<String, InterstitialAd> _cachedInterstitials = {};
  final Set<String> _loadingInterstitials = {};

  // Precached App Open Ads (keyed by ad unit ID)
  final Map<String, AppOpenAd> _cachedAppOpenAds = {};
  final Map<String, DateTime> _appOpenLoadTimes = {};
  final Set<String> _loadingAppOpenAds = {};

  // Precached Rewarded Ads (keyed by ad unit ID)
  final Map<String, RewardedAd> _cachedRewardedAds = {};
  final Set<String> _loadingRewardedAds = {};

  bool _isAdShowing = false;
  bool get isAdShowing => _isAdShowing;

  /// Initialize Google Mobile Ads SDK and start preloading cached ads.
  Future<void> init() async {
    if (_initialized) return;

    if (!AdIds.adsEnabled) {
      debugPrint('[AdService] Ads are globally disabled via AdIds.adsEnabled');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('[AdService] MobileAds initialized successfully');

      // Start preloading immediately in background
      if (AdIds.interstitialEnabled) {
        preloadInterstitial();
        preloadInterstitial(adUnitId: AdIds.onboardingInterstitialId);
      }
      if (AdIds.appOpenEnabled) {
        preloadAppOpenAd();
        preloadAppOpenAd(adUnitId: AdIds.onboardingAppOpenId);
      }
      if (AdIds.rewardedEnabled) {
        preloadRewardedAd(adUnitId: AdIds.onboardingRewardedId);
      }
    } catch (e, stack) {
      debugPrint('[AdService] Error initializing MobileAds: $e\n$stack');
    }
  }

  // ===========================================================================
  // INTERSTITIAL ADS (Preload, Precache & Display)
  // ===========================================================================

  /// Pre-caches an interstitial ad into memory for the given [adUnitId]
  /// (defaulting to [AdIds.interstitialAdId]) so it is ready for instant display.
  void preloadInterstitial({String? adUnitId}) {
    if (!AdIds.adsEnabled || !AdIds.interstitialEnabled) return;
    if (adUnitId != null && adUnitId.isEmpty) return;

    final targetUnitId = adUnitId ?? AdIds.interstitialAdId;
    if (targetUnitId.isEmpty) return;
    if (_cachedInterstitials.containsKey(targetUnitId) ||
        _loadingInterstitials.contains(targetUnitId)) {
      return;
    }
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _loadingInterstitials.add(targetUnitId);
    debugPrint('[AdService] Preloading Interstitial Ad ($targetUnitId)...');

    try {
      InterstitialAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _cachedInterstitials[targetUnitId] = ad;
            _loadingInterstitials.remove(targetUnitId);
            debugPrint(
              '[AdService] Interstitial Ad ($targetUnitId) ready in memory',
            );

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint(
                  '[AdService] Interstitial ($targetUnitId) dismissed. Disposing & re-preloading...',
                );
                ad.dispose();
                _cachedInterstitials.remove(targetUnitId);
                preloadInterstitial(adUnitId: targetUnitId);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint(
                  '[AdService] Interstitial ($targetUnitId) failed to show: $error. Disposing & re-preloading...',
                );
                ad.dispose();
                _cachedInterstitials.remove(targetUnitId);
                preloadInterstitial(adUnitId: targetUnitId);
              },
            );
          },
          onAdFailedToLoad: (error) {
            _cachedInterstitials.remove(targetUnitId);
            _loadingInterstitials.remove(targetUnitId);
            debugPrint(
              '[AdService] Interstitial ($targetUnitId) failed to preload: $error. Retrying in 15s...',
            );
            Future.delayed(const Duration(seconds: 15), () {
              preloadInterstitial(adUnitId: targetUnitId);
            });
          },
        ),
      );
    } catch (e) {
      _loadingInterstitials.remove(targetUnitId);
      debugPrint('[AdService] Platform error loading interstitial ad: $e');
    }
  }

  /// Displays the precached interstitial ad for [adUnitId] if ready and cooldown has passed.
  /// Falls back to any other ready precached interstitial if [adUnitId] is still loading.
  /// Calls [onComplete] when the ad is closed, if it fails, or if not ready.
  void showInterstitial({
    BuildContext? context,
    VoidCallback? onComplete,
    bool ignoreCooldown = false,
    String? adUnitId,
  }) {
    if (!AdIds.adsEnabled || !AdIds.interstitialEnabled) {
      onComplete?.call();
      return;
    }

    if (adUnitId != null && adUnitId.isEmpty) {
      debugPrint('[AdService] Interstitial skipped because adUnitId is empty');
      onComplete?.call();
      return;
    }

    final targetUnitId = adUnitId ?? AdIds.interstitialAdId;
    if (targetUnitId.isEmpty) {
      debugPrint('[AdService] Interstitial skipped because targetUnitId is empty');
      onComplete?.call();
      return;
    }

    // Prefer exact requested unit ID if ready; otherwise fallback to any preloaded unit
    String activeUnitId = targetUnitId;
    InterstitialAd? ad = _cachedInterstitials.remove(targetUnitId);

    if (ad == null && _cachedInterstitials.isNotEmpty) {
      activeUnitId = _cachedInterstitials.keys.first;
      ad = _cachedInterstitials.remove(activeUnitId);
      debugPrint(
        '[AdService] Exact unit $targetUnitId not cached yet, using preloaded $activeUnitId',
      );
    }

    if (ad != null) {
      debugPrint(
        '[AdService] Showing precached Interstitial Ad ($activeUnitId)',
      );

      bool completed = false;
      bool adShowing = false;
      void safeComplete() {
        if (!completed) {
          completed = true;
          onComplete?.call();
        }
      }

      // If ad fails to open within 2.5 seconds, do not block the app
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!completed && !adShowing) {
          debugPrint(
            '[AdService] Interstitial not showing in 2.5s, proceeding',
          );
          safeComplete();
        }
      });

      // Safety limit (25s) in case ad activity hangs completely
      Future.delayed(const Duration(seconds: 25), () {
        if (!completed) {
          debugPrint('[AdService] Safety timeout reached for Interstitial, proceeding navigation');
          safeComplete();
        }
      });

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _isAdShowing = true;
          adShowing = true;
          debugPrint('[AdService] Interstitial displayed full screen');
        },
        onAdDismissedFullScreenContent: (ad) {
          _isAdShowing = false;
          debugPrint('[AdService] Interstitial completed & dismissed');
          ad.dispose();
          safeComplete();
          // Preload next ads
          preloadInterstitial(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadInterstitial(adUnitId: targetUnitId);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isAdShowing = false;
          debugPrint('[AdService] Interstitial failed to show: $error');
          ad.dispose();
          safeComplete();
          preloadInterstitial(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadInterstitial(adUnitId: targetUnitId);
          }
        },
      );

      try {
        ad.show();
      } catch (e) {
        debugPrint('[AdService] Error during ad.show(): $e');
        ad.dispose();
        safeComplete();
        preloadInterstitial(adUnitId: activeUnitId);
        if (activeUnitId != targetUnitId) {
          preloadInterstitial(adUnitId: targetUnitId);
        }
      }
    } else {
      debugPrint(
        '[AdService] No precached Interstitial available for $targetUnitId, proceeding directly',
      );
      onComplete?.call();
      preloadInterstitial(adUnitId: targetUnitId);
    }
  }

  // ===========================================================================
  // APP OPEN ADS (Preload, Precache & Display)
  // ===========================================================================

  /// Preloads an App Open Ad into memory for [adUnitId].
  void preloadAppOpenAd({String? adUnitId}) {
    if (!AdIds.adsEnabled || !AdIds.appOpenEnabled) return;

    final targetUnitId = adUnitId ?? AdIds.appOpenAdId;
    if (_cachedAppOpenAds.containsKey(targetUnitId) ||
        _loadingAppOpenAds.contains(targetUnitId)) {
      return;
    }
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _loadingAppOpenAds.add(targetUnitId);
    debugPrint('[AdService] Preloading App Open Ad ($targetUnitId)...');

    try {
      AppOpenAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _cachedAppOpenAds[targetUnitId] = ad;
            _loadingAppOpenAds.remove(targetUnitId);
            _appOpenLoadTimes[targetUnitId] = DateTime.now();
            debugPrint(
              '[AdService] App Open Ad ($targetUnitId) ready in memory',
            );
          },
          onAdFailedToLoad: (error) {
            _cachedAppOpenAds.remove(targetUnitId);
            _loadingAppOpenAds.remove(targetUnitId);
            debugPrint(
              '[AdService] App Open Ad ($targetUnitId) failed: $error. Retrying in 15s...',
            );
            Future.delayed(const Duration(seconds: 15), () {
              preloadAppOpenAd(adUnitId: targetUnitId);
            });
          },
        ),
      );
    } catch (e) {
      _loadingAppOpenAds.remove(targetUnitId);
      debugPrint('[AdService] Platform error loading app open ad: $e');
    }
  }

  /// Displays the App Open Ad (e.g. from Splash screen or on cold start).
  void showAppOpenAd({VoidCallback? onComplete, String? adUnitId}) {
    if (!AdIds.adsEnabled || !AdIds.appOpenEnabled) {
      onComplete?.call();
      return;
    }

    if (_isAdShowing) {
      debugPrint('[AdService] Another ad is currently active, skipping App Open ad');
      onComplete?.call();
      return;
    }

    final targetUnitId = adUnitId ?? AdIds.appOpenAdId;
    String activeUnitId = targetUnitId;
    AppOpenAd? ad = _cachedAppOpenAds.remove(targetUnitId);
    DateTime? loadTime = _appOpenLoadTimes.remove(targetUnitId);

    // Fallback to any ready cached app open ad if exact unit is not cached
    if (ad == null && _cachedAppOpenAds.isNotEmpty) {
      activeUnitId = _cachedAppOpenAds.keys.first;
      ad = _cachedAppOpenAds.remove(activeUnitId);
      loadTime = _appOpenLoadTimes.remove(activeUnitId);
      debugPrint(
        '[AdService] Exact App Open unit $targetUnitId not cached yet, using preloaded $activeUnitId',
      );
    }

    // Google AdMob App Open ads expire after 4 hours
    final isExpired =
        loadTime != null && DateTime.now().difference(loadTime).inHours >= 4;

    if (ad != null && !isExpired) {
      debugPrint('[AdService] Showing precached App Open Ad ($activeUnitId)');
      bool completed = false;
      bool adShowing = false;
      void safeComplete() {
        if (!completed) {
          completed = true;
          onComplete?.call();
        }
      }

      // If ad fails to open within 2.5 seconds, do not block the app
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!completed && !adShowing) {
          debugPrint(
            '[AdService] App open ad not showing in 2.5s, proceeding',
          );
          safeComplete();
        }
      });

      // Safety timeout in case ad hangs completely
      Future.delayed(const Duration(seconds: 25), () {
        if (!completed) {
          debugPrint(
            '[AdService] Max app open ad display timeout reached, proceeding',
          );
          safeComplete();
        }
      });

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _isAdShowing = true;
          adShowing = true;
          debugPrint('[AdService] App Open Ad displayed full screen');
        },
        onAdDismissedFullScreenContent: (ad) {
          _isAdShowing = false;
          ad.dispose();
          safeComplete();
          preloadAppOpenAd(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadAppOpenAd(adUnitId: targetUnitId);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isAdShowing = false;
          ad.dispose();
          safeComplete();
          preloadAppOpenAd(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadAppOpenAd(adUnitId: targetUnitId);
          }
        },
      );
      try {
        ad.show();
      } catch (e) {
        debugPrint('[AdService] Error showing app open ad: $e');
        ad.dispose();
        safeComplete();
        preloadAppOpenAd(adUnitId: activeUnitId);
      }
    } else {
      debugPrint(
        '[AdService] App Open Ad ($targetUnitId) not cached yet, attempting on-demand load...',
      );
      try {
        AppOpenAd.load(
          adUnitId: targetUnitId,
          request: const AdRequest(),
          adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: (loadedAd) {
              debugPrint('[AdService] On-demand App Open Ad ($targetUnitId) ready, displaying now');
              _cachedAppOpenAds[targetUnitId] = loadedAd;
              _appOpenLoadTimes[targetUnitId] = DateTime.now();
              showAppOpenAd(onComplete: onComplete, adUnitId: targetUnitId);
            },
            onAdFailedToLoad: (error) {
              debugPrint('[AdService] On-demand App Open Ad ($targetUnitId) failed: $error');
              onComplete?.call();
              Future.delayed(const Duration(seconds: 15), () {
                preloadAppOpenAd(adUnitId: targetUnitId);
              });
            },
          ),
        );
      } catch (e) {
        debugPrint('[AdService] Error during on-demand App Open Ad load: $e');
        onComplete?.call();
        preloadAppOpenAd(adUnitId: targetUnitId);
      }
    }
  }

  // ===========================================================================
  // REWARDED ADS (Preload, Precache & Display)
  // ===========================================================================

  /// Preloads a Rewarded Ad into memory for [adUnitId].
  void preloadRewardedAd({String? adUnitId}) {
    if (!AdIds.adsEnabled || !AdIds.rewardedEnabled) return;

    final targetUnitId = adUnitId ?? AdIds.rewardedAdId;
    if (_cachedRewardedAds.containsKey(targetUnitId) ||
        _loadingRewardedAds.contains(targetUnitId)) {
      return;
    }
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    _loadingRewardedAds.add(targetUnitId);
    debugPrint('[AdService] Preloading Rewarded Ad ($targetUnitId)...');

    try {
      RewardedAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _cachedRewardedAds[targetUnitId] = ad;
            _loadingRewardedAds.remove(targetUnitId);
            debugPrint(
              '[AdService] Rewarded Ad ($targetUnitId) ready in memory',
            );

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _cachedRewardedAds.remove(targetUnitId);
                preloadRewardedAd(adUnitId: targetUnitId);
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _cachedRewardedAds.remove(targetUnitId);
                preloadRewardedAd(adUnitId: targetUnitId);
              },
            );
          },
          onAdFailedToLoad: (error) {
            _cachedRewardedAds.remove(targetUnitId);
            _loadingRewardedAds.remove(targetUnitId);
            debugPrint(
              '[AdService] Rewarded Ad ($targetUnitId) failed: $error',
            );
            Future.delayed(const Duration(seconds: 15), () {
              preloadRewardedAd(adUnitId: targetUnitId);
            });
          },
        ),
      );
    } catch (e) {
      _loadingRewardedAds.remove(targetUnitId);
      debugPrint('[AdService] Platform error loading rewarded ad: $e');
    }
  }

  /// Displays the precached Rewarded Ad for [adUnitId].
  /// Falls back to any preloaded rewarded ad if available.
  /// Calls [onComplete] when closed, skipped, or failed.
  /// Calls [onUserEarnedReward] if the reward was achieved.
  void showRewardedAd({
    BuildContext? context,
    VoidCallback? onComplete,
    void Function(RewardItem)? onUserEarnedReward,
    String? adUnitId,
  }) {
    if (!AdIds.adsEnabled || !AdIds.rewardedEnabled) {
      onComplete?.call();
      return;
    }

    final targetUnitId = adUnitId ?? AdIds.rewardedAdId;
    String activeUnitId = targetUnitId;
    RewardedAd? ad = _cachedRewardedAds.remove(targetUnitId);

    if (ad == null && _cachedRewardedAds.isNotEmpty) {
      activeUnitId = _cachedRewardedAds.keys.first;
      ad = _cachedRewardedAds.remove(activeUnitId);
      debugPrint(
        '[AdService] Exact Rewarded unit $targetUnitId not cached yet, using preloaded $activeUnitId',
      );
    }

    if (ad != null) {
      debugPrint('[AdService] Showing precached Rewarded Ad ($activeUnitId)');
      bool completed = false;
      bool adShowing = false;
      void safeComplete() {
        if (!completed) {
          completed = true;
          onComplete?.call();
        }
      }

      // Safety timeout in case ad fails to show
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!completed && !adShowing) {
          debugPrint('[AdService] Rewarded ad not showing in 2.5s, proceeding');
          safeComplete();
        }
      });

      // Max display safety timeout (rewarded ads can run 15-35s)
      Future.delayed(const Duration(seconds: 40), () {
        if (!completed) {
          debugPrint(
            '[AdService] Max rewarded ad display timeout reached, proceeding',
          );
          safeComplete();
        }
      });

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _isAdShowing = true;
          adShowing = true;
          debugPrint('[AdService] Rewarded Ad displayed full screen');
        },
        onAdDismissedFullScreenContent: (ad) {
          _isAdShowing = false;
          debugPrint('[AdService] Rewarded Ad dismissed');
          ad.dispose();
          safeComplete();
          preloadRewardedAd(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadRewardedAd(adUnitId: targetUnitId);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _isAdShowing = false;
          debugPrint('[AdService] Rewarded Ad failed to show: $error');
          ad.dispose();
          safeComplete();
          preloadRewardedAd(adUnitId: activeUnitId);
          if (activeUnitId != targetUnitId) {
            preloadRewardedAd(adUnitId: targetUnitId);
          }
        },
      );

      try {
        ad.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            debugPrint(
              '[AdService] User earned reward: ${reward.amount} ${reward.type}',
            );
            onUserEarnedReward?.call(reward);
          },
        );
      } catch (e) {
        debugPrint('[AdService] Error showing rewarded ad: $e');
        ad.dispose();
        safeComplete();
        preloadRewardedAd(adUnitId: activeUnitId);
        if (activeUnitId != targetUnitId) {
          preloadRewardedAd(adUnitId: targetUnitId);
        }
      }
    } else {
      debugPrint(
        '[AdService] No precached Rewarded Ad available for $targetUnitId, proceeding directly',
      );
      onComplete?.call();
      preloadRewardedAd(adUnitId: targetUnitId);
    }
  }

  // ===========================================================================
  // BANNER AD FACTORY
  // ===========================================================================

  /// Creates a BannerAd instance configured with the resolved ad unit ID.
  BannerAd createBannerAd({
    String? adUnitId,
    AdSize size = AdSize.banner,
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: adUnitId ?? AdIds.bannerAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
