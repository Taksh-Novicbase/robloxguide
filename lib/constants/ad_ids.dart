import '../services/remote_config_service.dart';

/// Centralized AdMob Ad Unit IDs and Configuration.
///
/// Flow-wise separated AdMob unit IDs allowing individual production IDs per
/// screen and flow, while providing seamless Google official test IDs during development.
///
/// Easily switch between test ads and production ads using [useTestAds].
class AdIds {
  AdIds._();

  /// Test override hook
  static bool? debugOverrideUseTestAds;

  /// Set to `true` to use Google's official AdMob test unit IDs.
  /// Set to `false` when deploying with live production / Remote Config IDs.
  static bool get useTestAds => debugOverrideUseTestAds ?? false;

  /// Global master switch to enable/disable ads across the entire app.
  /// Controlled dynamically by Firebase Remote Config `show_ad` flag.
  static bool get adsEnabled => RemoteConfigService.instance.showAd;

  /// Feature toggles for each ad format.
  static const bool bannerEnabled = true;
  static const bool interstitialEnabled = true;
  static const bool nativeEnabled = true;
  static const bool nativeSmallEnabled = true;
  static const bool nativeMediumEnabled = true;
  static const bool appOpenEnabled = true;
  static const bool rewardedEnabled = true;

  /// Cooldown between interstitial ads (in seconds). Set to 0 to allow on-transition interstitial ads matching APK.
  static const int interstitialCooldownSeconds = 0;

  // ===========================================================================
  // PRODUCTION AD IDS (FLOW-WISE SEPARATE)
  // Dynamically resolved from Firebase Remote Config `ads_id` JSON parameter,
  // falling back to hardcoded default IDs if offline or unconfigured.
  // ===========================================================================

  /// Global AdMob App ID
  static const String _defaultProdAppId =
      'ca-app-pub-1234444627237787~4196102084';
  static String get prodAppId =>
      RemoteConfigService.instance.getAdUnitId('prodAppId', _defaultProdAppId);

  // --- 1. FLOW: SPLASH ---
  static const String _defaultSplashAppOpenId =
      'ca-app-pub-1234444627237787/8472765152';
  static String get prodSplashAppOpenId => RemoteConfigService.instance
      .getAdUnitId('prodSplashAppOpenId', _defaultSplashAppOpenId);

  static const String _defaultSplashInterstitialId =
      'ca-app-pub-1234444627237787/4552245177';
  static String get prodSplashInterstitialId => RemoteConfigService.instance
      .getAdUnitId('prodSplashInterstitialId', _defaultSplashInterstitialId);

  // --- 2. FLOW: DEFAULT LAUNCHER SCREEN ---
  static const String _defaultDefaultLauncherBannerId =
      'ca-app-pub-1234444627237787/6664859463';
  static String get prodDefaultLauncherBannerId =>
      RemoteConfigService.instance.getAdUnitId(
        'prodDefaultLauncherBannerId',
        _defaultDefaultLauncherBannerId,
      );

  static const String _defaultDefaultLauncherInterstitialId =
      'ca-app-pub-1234444627237787/2723238314';
  static String get prodDefaultLauncherInterstitialId =>
      RemoteConfigService.instance.getAdUnitId(
        'prodDefaultLauncherInterstitialId',
        _defaultDefaultLauncherInterstitialId,
      );

  // --- 3. FLOW: ONBOARDING & GET STARTED ---
  static const String _defaultOnboardingBannerId =
      'ca-app-pub-1234444627237787/4331833459';
  static String get prodOnboardingBannerId => RemoteConfigService.instance
      .getAdUnitId('prodOnboardingBannerId', _defaultOnboardingBannerId);

  static const String _defaultOnboardingNativeId =
      'ca-app-pub-1234444627237787/6384201591';
  static String get prodOnboardingNativeId => RemoteConfigService.instance
      .getAdUnitId('prodOnboardingNativeId', _defaultOnboardingNativeId);

  static const String _defaultOnboardingInterstitialId =
      'ca-app-pub-1234444627237787/8869844260';
  static String get prodOnboardingInterstitialId =>
      RemoteConfigService.instance.getAdUnitId(
        'prodOnboardingInterstitialId',
        _defaultOnboardingInterstitialId,
      );

  static const String _defaultOnboardingRewardedId =
      'ca-app-pub-1234444627237787/1378367056';
  static String get prodOnboardingRewardedId => RemoteConfigService.instance
      .getAdUnitId('prodOnboardingRewardedId', _defaultOnboardingRewardedId);

  static const String _defaultOnboardingAppOpenId =
      'ca-app-pub-1234444627237787/3758038258';
  static String get prodOnboardingAppOpenId => RemoteConfigService.instance
      .getAdUnitId('prodOnboardingAppOpenId', _defaultOnboardingAppOpenId);

  // --- 4. FLOW: HOME HUB SCREEN ---
  static const String _defaultHomeBannerId =
      'ca-app-pub-1234444627237787/7389241635';
  static String get prodHomeBannerId => RemoteConfigService.instance
      .getAdUnitId('prodHomeBannerId', _defaultHomeBannerId);

  static const String _defaultHomeNativeId =
      'ca-app-pub-1234444627237787/8925684584';
  static String get prodHomeNativeId => RemoteConfigService.instance
      .getAdUnitId('prodHomeNativeId', _defaultHomeNativeId);

  static const String _defaultHomeInterstitialId =
      'ca-app-pub-1234444627237787/7916775116';
  static String get prodHomeInterstitialId => RemoteConfigService.instance
      .getAdUnitId('prodHomeInterstitialId', _defaultHomeInterstitialId);

  // --- 5. FLOW: OUTFIT / SKINS BROWSER ---
  static const String _defaultOutfitBannerId =
      'ca-app-pub-1234444627237787/7887935081';
  static String get prodOutfitBannerId => RemoteConfigService.instance
      .getAdUnitId('prodOutfitBannerId', _defaultOutfitBannerId);

  static const String _defaultOutfitNativeId =
      'ca-app-pub-1234444627237787/7725203427';
  static String get prodOutfitNativeId => RemoteConfigService.instance
      .getAdUnitId('prodOutfitNativeId', _defaultOutfitNativeId);

  static const String _defaultOutfitInterstitialId =
      'ca-app-pub-1234444627237787/2281305052';
  static String get prodOutfitInterstitialId => RemoteConfigService.instance
      .getAdUnitId('prodOutfitInterstitialId', _defaultOutfitInterstitialId);

  // --- 6. FLOW: TOOLS & GAMES (Calculator, Converters, Quiz, Spin, Scratch, Memes, Redeem, Settings) ---
  static const String _defaultToolsBannerId =
      'ca-app-pub-1234444627237787/7505711570';
  static String get prodToolsBannerId => RemoteConfigService.instance
      .getAdUnitId('prodToolsBannerId', _defaultToolsBannerId);

  static const String _defaultToolsNativeId =
      'ca-app-pub-1234444627237787/5126040379';
  static String get prodToolsNativeId => RemoteConfigService.instance
      .getAdUnitId('prodToolsNativeId', _defaultToolsNativeId);

  static const String _defaultToolsInterstitialId =
      'ca-app-pub-1234444627237787/8486700884';
  static String get prodToolsInterstitialId => RemoteConfigService.instance
      .getAdUnitId('prodToolsInterstitialId', _defaultToolsInterstitialId);

  static const String _defaultToolsRewardedId =
      'ca-app-pub-1234444627237787/7173619214';
  static String get prodToolsRewardedId => RemoteConfigService.instance
      .getAdUnitId('prodToolsRewardedId', _defaultToolsRewardedId);

  // --- 7. FLOW: LAUNCHER (Drawer Sticky Native, Widgets & Desktop) ---
  static const String _defaultLauncherNativeId =
      'ca-app-pub-1234444627237787/9632261596';
  static String get prodLauncherNativeId => RemoteConfigService.instance
      .getAdUnitId('prodLauncherNativeId', _defaultLauncherNativeId);

  static const String _defaultLauncherBannerId =
      'ca-app-pub-1234444627237787/9009445065';
  static String get prodLauncherBannerId => RemoteConfigService.instance
      .getAdUnitId('prodLauncherBannerId', _defaultLauncherBannerId);

  static const String _defaultLauncherInterstitialId =
      'ca-app-pub-1234444627237787/9009445065';
  static String get prodLauncherInterstitialId =>
      RemoteConfigService.instance.getAdUnitId(
        'prodLauncherInterstitialId',
        _defaultLauncherInterstitialId,
      );

  // ===========================================================================
  // FALLBACK GENERIC PRODUCTION IDS (For Backward Compatibility)
  // ===========================================================================
  static String get prodBannerAdId => prodHomeBannerId;
  static String get prodInterstitialAdId => prodHomeInterstitialId;
  static String get prodNativeAdId => prodHomeNativeId;
  static String get prodAppOpenAdId => prodSplashAppOpenId;
  static String get prodRewardedAdId => prodToolsRewardedId;

  // ===========================================================================
  // GOOGLE OFFICIAL TEST AD UNIT IDS (Android)
  // Safe for development and automated testing without policy violations.
  // ===========================================================================
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testNativeAdId = 'ca-app-pub-3940256099942544/2247696110';
  static const String testAppOpenAdId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String testRewardedAdId =
      'ca-app-pub-3940256099942544/5224354917';

  // ===========================================================================
  // RESOLVED AD UNIT IDS (Dynamic Test / Prod Switching)
  // ===========================================================================

  // Global / Fallbacks
  static String get appId => useTestAds ? testAppId : prodAppId;
  static String get bannerAdId => useTestAds ? testBannerAdId : prodBannerAdId;
  static String get interstitialAdId =>
      useTestAds ? testInterstitialAdId : prodInterstitialAdId;
  static String get nativeAdId => useTestAds ? testNativeAdId : prodNativeAdId;
  static String get nativeSmallAdId => nativeAdId;
  static String get nativeMediumAdId => nativeAdId;
  static String get appOpenAdId =>
      useTestAds ? testAppOpenAdId : prodAppOpenAdId;
  static String get rewardedAdId =>
      useTestAds ? testRewardedAdId : prodRewardedAdId;

  // --- 1. Splash Flow ---
  static String get splashAppOpenId =>
      useTestAds ? testAppOpenAdId : prodSplashAppOpenId;
  static String get splashInterstitialId =>
      useTestAds ? testInterstitialAdId : prodSplashInterstitialId;

  // --- 2. Default Launcher Flow ---
  static String get defaultLauncherBannerId =>
      useTestAds ? testBannerAdId : prodDefaultLauncherBannerId;
  static String get defaultLauncherInterstitialId =>
      useTestAds ? testInterstitialAdId : prodDefaultLauncherInterstitialId;

  // --- 3. Onboarding Flow ---
  static String get onboardingBannerId =>
      useTestAds ? testBannerAdId : prodOnboardingBannerId;
  static String get onboardingNativeId =>
      useTestAds ? testNativeAdId : prodOnboardingNativeId;
  static String get onboardingInterstitialId =>
      useTestAds ? testInterstitialAdId : prodOnboardingInterstitialId;
  static String get onboardingRewardedId =>
      useTestAds ? testRewardedAdId : prodOnboardingRewardedId;
  static String get onboardingAppOpenId =>
      useTestAds ? testAppOpenAdId : prodOnboardingAppOpenId;

  // --- 4. Home Hub Flow ---
  static String get homeBannerId =>
      useTestAds ? testBannerAdId : prodHomeBannerId;
  static String get homeNativeId =>
      useTestAds ? testNativeAdId : prodHomeNativeId;
  static String get homeInterstitialId =>
      useTestAds ? testInterstitialAdId : prodHomeInterstitialId;

  // --- 5. Outfit / Skins Flow ---
  static String get outfitBannerId =>
      useTestAds ? testBannerAdId : prodOutfitBannerId;
  static String get outfitNativeId =>
      useTestAds ? testNativeAdId : prodOutfitNativeId;
  static String get outfitInterstitialId =>
      useTestAds ? testInterstitialAdId : prodOutfitInterstitialId;

  // --- 6. Tools & Games Flow ---
  static String get toolsBannerId =>
      useTestAds ? testBannerAdId : prodToolsBannerId;
  static String get toolsNativeId =>
      useTestAds ? testNativeAdId : prodToolsNativeId;
  static String get toolsInterstitialId =>
      useTestAds ? testInterstitialAdId : prodToolsInterstitialId;
  static String get toolsRewardedId =>
      useTestAds ? testRewardedAdId : prodToolsRewardedId;

  // --- 7. Launcher Flow ---
  static String get launcherNativeId =>
      useTestAds ? testNativeAdId : prodLauncherNativeId;
  static String get launcherBannerId =>
      useTestAds ? testBannerAdId : prodLauncherBannerId;
  static String get launcherInterstitialId =>
      useTestAds ? testInterstitialAdId : prodLauncherInterstitialId;

  /// Returns all production AdMob App & Unit IDs as a JSON-compatible Map.
  static Map<String, String> get prodIdsJsonMap => {
        'prodAppId': prodAppId,
        'prodSplashAppOpenId': prodSplashAppOpenId,
        'prodSplashInterstitialId': prodSplashInterstitialId,
        'prodDefaultLauncherBannerId': prodDefaultLauncherBannerId,
        'prodDefaultLauncherInterstitialId': prodDefaultLauncherInterstitialId,
        'prodOnboardingBannerId': prodOnboardingBannerId,
        'prodOnboardingNativeId': prodOnboardingNativeId,
        'prodOnboardingInterstitialId': prodOnboardingInterstitialId,
        'prodOnboardingRewardedId': prodOnboardingRewardedId,
        'prodOnboardingAppOpenId': prodOnboardingAppOpenId,
        'prodHomeBannerId': prodHomeBannerId,
        'prodHomeNativeId': prodHomeNativeId,
        'prodHomeInterstitialId': prodHomeInterstitialId,
        'prodOutfitBannerId': prodOutfitBannerId,
        'prodOutfitNativeId': prodOutfitNativeId,
        'prodOutfitInterstitialId': prodOutfitInterstitialId,
        'prodToolsBannerId': prodToolsBannerId,
        'prodToolsNativeId': prodToolsNativeId,
        'prodToolsInterstitialId': prodToolsInterstitialId,
        'prodToolsRewardedId': prodToolsRewardedId,
        'prodLauncherNativeId': prodLauncherNativeId,
        'prodLauncherBannerId': prodLauncherBannerId,
        'prodLauncherInterstitialId': prodLauncherInterstitialId,
      };
}
