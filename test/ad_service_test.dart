import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_skins_tool/constants/ad_ids.dart';
import 'package:rbx_skins_tool/services/ad_service.dart';
import 'package:rbx_skins_tool/widgets/native_ad_card_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdIds Configuration Tests', () {
    test('Default mode has production ads with real IDs configured', () {
      expect(AdIds.useTestAds, isFalse);
      expect(AdIds.adsEnabled, isTrue);
      expect(AdIds.bannerEnabled, isTrue);
      expect(AdIds.interstitialEnabled, isTrue);
      expect(AdIds.nativeEnabled, isTrue);
      expect(AdIds.nativeSmallEnabled, isTrue);
      expect(AdIds.nativeMediumEnabled, isTrue);

      expect(AdIds.appId, equals(AdIds.prodAppId));
      expect(AdIds.prodAppId, equals('ca-app-pub-1234444627237787~4196102084'));
      expect(AdIds.prodSplashAppOpenId, equals('ca-app-pub-1234444627237787/8472765152'));
      expect(AdIds.prodSplashInterstitialId, equals('ca-app-pub-1234444627237787/4552245177'));
      expect(AdIds.prodDefaultLauncherBannerId, equals('ca-app-pub-1234444627237787/6664859463'));
      expect(AdIds.prodDefaultLauncherInterstitialId, equals('ca-app-pub-1234444627237787/2723238314'));
      expect(AdIds.prodOnboardingBannerId, equals('ca-app-pub-1234444627237787/4331833459'));
      expect(AdIds.prodOnboardingNativeId, equals('ca-app-pub-1234444627237787/6384201591'));
      expect(AdIds.prodOnboardingInterstitialId, equals('ca-app-pub-1234444627237787/8869844260'));
      expect(AdIds.prodOnboardingRewardedId, equals('ca-app-pub-1234444627237787/1378367056'));
      expect(AdIds.prodOnboardingAppOpenId, equals('ca-app-pub-1234444627237787/3758038258'));
      expect(AdIds.prodHomeBannerId, equals('ca-app-pub-1234444627237787/7389241635'));
      expect(AdIds.prodHomeNativeId, equals('ca-app-pub-1234444627237787/8925684584'));
      expect(AdIds.prodHomeInterstitialId, equals('ca-app-pub-1234444627237787/7916775116'));
      expect(AdIds.prodOutfitBannerId, equals('ca-app-pub-1234444627237787/7887935081'));
      expect(AdIds.prodOutfitNativeId, equals('ca-app-pub-1234444627237787/7725203427'));
      expect(AdIds.prodOutfitInterstitialId, equals('ca-app-pub-1234444627237787/2281305052'));
      expect(AdIds.prodToolsBannerId, equals('ca-app-pub-1234444627237787/7505711570'));
      expect(AdIds.prodToolsNativeId, equals('ca-app-pub-1234444627237787/5126040379'));
      expect(AdIds.prodToolsInterstitialId, equals('ca-app-pub-1234444627237787/8486700884'));
      expect(AdIds.prodToolsRewardedId, equals('ca-app-pub-1234444627237787/7173619214'));
      expect(AdIds.prodLauncherNativeId, equals('ca-app-pub-1234444627237787/9632261596'));
      expect(AdIds.prodLauncherBannerId, equals('ca-app-pub-1234444627237787/9009445065'));
      expect(AdIds.prodLauncherInterstitialId, equals('ca-app-pub-1234444627237787/9009445065'));
    });

    test('Test mode override enables Google test ad unit IDs', () {
      AdIds.debugOverrideUseTestAds = true;
      expect(AdIds.useTestAds, isTrue);
      expect(AdIds.appId, equals(AdIds.testAppId));
      expect(AdIds.bannerAdId, equals(AdIds.testBannerAdId));
      expect(AdIds.interstitialAdId, equals(AdIds.testInterstitialAdId));
      expect(AdIds.nativeAdId, equals(AdIds.testNativeAdId));
      AdIds.debugOverrideUseTestAds = null;
    });

    test('Ad IDs have correct standard AdMob formatting', () {
      expect(AdIds.appId, startsWith('ca-app-pub-'));
      expect(AdIds.bannerAdId, startsWith('ca-app-pub-'));
      expect(AdIds.interstitialAdId, startsWith('ca-app-pub-'));
      expect(AdIds.nativeAdId, startsWith('ca-app-pub-'));
      expect(AdIds.appOpenAdId, startsWith('ca-app-pub-'));
    });

  });

  group('AdService Pre-caching and Preloading Tests', () {
    test('AdService singleton instance exists and handles showInterstitial with onComplete callback', () {
      final service = AdService.instance;
      expect(service, isNotNull);

      // When interstitial ad is not yet cached or loaded, showInterstitial should invoke onComplete gracefully
      var completed = false;
      service.showInterstitial(
        onComplete: () {
          completed = true;
        },
      );
      expect(completed, isTrue);
    });
  });

  group('Native Ad Widgets Tests', () {
    testWidgets('SmallNativeAdWidget renders properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmallNativeAdWidget(),
          ),
        ),
      );
      expect(find.byType(SmallNativeAdWidget), findsOneWidget);
    });

    testWidgets('MediumNativeAdWidget renders properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MediumNativeAdWidget(),
          ),
        ),
      );
      expect(find.byType(MediumNativeAdWidget), findsOneWidget);
    });
  });
}

