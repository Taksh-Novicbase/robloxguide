import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_ids.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

/// Reusable Banner Ad Widget mirroring `id/banner_container` from the reference APK.
///
/// Features:
/// - Pre-loading & lifecycle management (auto-disposal)
/// - Shimmer placeholder while loading (mirrors `ad_layout_shimmer_banner.xml`)
/// - Graceful collapse if ads are disabled or fail to load
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry padding;
  final String? adUnitId;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!AdIds.adsEnabled || !AdIds.bannerEnabled) {
      return;
    }

    // On non-mobile test platforms (like Windows/Desktop development), do not attempt platform views
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    try {
      _bannerAd = AdService.instance.createBannerAd(
        adUnitId: widget.adUnitId ?? AdIds.bannerAdId,
        size: widget.adSize,
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _hasFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[BannerAdWidget] Banner failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _hasFailed = true;
          });
        },
      );
      _bannerAd!.load();
    } catch (e) {
      debugPrint('[BannerAdWidget] Exception creating banner: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdIds.adsEnabled || !AdIds.bannerEnabled || _hasFailed) {
      return const SizedBox.shrink();
    }

    final width = widget.adSize.width.toDouble();
    final height = widget.adSize.height.toDouble();

    if (_isLoaded && _bannerAd != null) {
      return Padding(
        padding: widget.padding,
        child: Center(
          child: SizedBox(
            width: width > 0 ? width : double.infinity,
            height: height,
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }

    // Shimmer placeholder while loading (matches ad_layout_shimmer_banner.xml)
    return Padding(
      padding: widget.padding,
      child: Center(
        child: Container(
          width: width > 0 ? width : 320,
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.surface.withAlpha(120),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(20), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(60),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Advertisement',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
