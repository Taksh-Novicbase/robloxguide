/// Centralized AdMob Ad Unit IDs and Configuration.
///
/// Flow-wise separated AdMob unit IDs allowing individual production IDs per
/// screen and flow, while providing seamless Google official test IDs during development.
///
/// Easily switch between test ads and production ads using [useTestAds].
class AdIds {
  AdIds._();

  /// Set to `true` to use Google's official AdMob test unit IDs.
  /// Set to `false` when deploying with live production IDs.
  static const bool useTestAds = true;

  /// Global master switch to enable/disable ads across the entire app.
  static const bool adsEnabled = true;

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
  // Replace the IDs below with your live AdMob Ad Unit IDs for each specific flow.
  // ===========================================================================

  /// Global AdMob App ID
  static const String prodAppId = 'ca-app-pub-3940256099942544~3347511713';

  // --- 1. FLOW: SPLASH ---
  static const String prodSplashAppOpenId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String prodSplashInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // --- 2. FLOW: DEFAULT LAUNCHER SCREEN ---
  static const String prodDefaultLauncherBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodDefaultLauncherInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // --- 3. FLOW: ONBOARDING & GET STARTED ---
  static const String prodOnboardingBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodOnboardingNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String prodOnboardingInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String prodOnboardingRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String prodOnboardingAppOpenId =
      'ca-app-pub-3940256099942544/9257395921';

  // --- 4. FLOW: HOME HUB SCREEN ---
  static const String prodHomeBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodHomeNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String prodHomeInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // --- 5. FLOW: OUTFIT / SKINS BROWSER ---
  static const String prodOutfitBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodOutfitNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String prodOutfitInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // --- 6. FLOW: TOOLS & GAMES (Calculator, Converters, Quiz, Spin, Scratch, Memes, Redeem, Settings) ---
  static const String prodToolsBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodToolsNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String prodToolsInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String prodToolsRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // --- 7. FLOW: LAUNCHER (Drawer Sticky Native, Widgets & Desktop) ---
  static const String prodLauncherNativeId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String prodLauncherBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String prodLauncherInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // ===========================================================================
  // FALLBACK GENERIC PRODUCTION IDS (For Backward Compatibility)
  // ===========================================================================
  static const String prodBannerAdId = prodHomeBannerId;
  static const String prodInterstitialAdId = prodHomeInterstitialId;
  static const String prodNativeAdId = prodHomeNativeId;
  static const String prodAppOpenAdId = prodSplashAppOpenId;
  static const String prodRewardedAdId = prodToolsRewardedId;

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
}
