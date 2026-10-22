import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_skins_tool/constants/ad_ids.dart';
import 'package:rbx_skins_tool/services/ad_service.dart';
import 'package:rbx_skins_tool/widgets/native_ad_card_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdIds Configuration Tests', () {
    test('Default mode has test ads enabled and resolved IDs valid', () {
      expect(AdIds.useTestAds, isTrue);
      expect(AdIds.adsEnabled, isTrue);
      expect(AdIds.bannerEnabled, isTrue);
      expect(AdIds.interstitialEnabled, isTrue);
      expect(AdIds.nativeEnabled, isTrue);
      expect(AdIds.nativeSmallEnabled, isTrue);
      expect(AdIds.nativeMediumEnabled, isTrue);

      expect(AdIds.appId, equals(AdIds.testAppId));
      expect(AdIds.bannerAdId, equals(AdIds.testBannerAdId));
      expect(AdIds.interstitialAdId, equals(AdIds.testInterstitialAdId));
      expect(AdIds.nativeAdId, equals(AdIds.testNativeAdId));
      expect(AdIds.nativeSmallAdId, equals(AdIds.testNativeAdId));
      expect(AdIds.nativeMediumAdId, equals(AdIds.testNativeAdId));
      expect(AdIds.appOpenAdId, equals(AdIds.testAppOpenAdId));
      expect(AdIds.rewardedAdId, equals(AdIds.testRewardedAdId));
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

