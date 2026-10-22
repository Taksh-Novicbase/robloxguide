import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_ids.dart';
import '../theme/app_theme.dart';

/// Supported Native Ad sizes matching the APK's templates:
/// - [NativeAdSize.small]: Compact banner-style native ad (~90-110dp), matches `ad_unit_admob_small.xml`
/// - [NativeAdSize.medium]: Card-style with 130dp MediaView & CTA (~290-320dp), matches `ad_unit_admob_med.xml`
enum NativeAdSize {
  small,
  medium,
}

/// Convenience widget for Small Native Ads (`ad_unit_admob_small.xml`).
class SmallNativeAdWidget extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final String? adUnitId;

  const SmallNativeAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.adUnitId,
  });

  @override
  Widget build(BuildContext context) {
    return NativeAdCardWidget(
      size: NativeAdSize.small,
      margin: margin,
      adUnitId: adUnitId,
    );
  }
}

/// Convenience widget for Medium Native Ads (`ad_unit_admob_med.xml`).
class MediumNativeAdWidget extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final String? adUnitId;

  const MediumNativeAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.adUnitId,
  });

  @override
  Widget build(BuildContext context) {
    return NativeAdCardWidget(
      size: NativeAdSize.medium,
      margin: margin,
      adUnitId: adUnitId,
    );
  }
}

/// Comprehensive Native Ad Widget supporting both Small and Medium templates.
///
/// Closely mirrors the decompiled layouts from the reference APK:
/// - Small: `ad_unit_admob_small.xml`
/// - Medium: `ad_unit_admob_med.xml`
class NativeAdCardWidget extends StatefulWidget {
  final NativeAdSize size;
  final EdgeInsetsGeometry margin;
  final String? adUnitId;

  /// Backwards-compatible constructor allowing `compact: true` (which selects [NativeAdSize.small]).
  const NativeAdCardWidget({
    super.key,
    NativeAdSize? size,
    bool compact = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.adUnitId,
  }) : size = size ?? (compact ? NativeAdSize.small : NativeAdSize.medium);

  @override
  State<NativeAdCardWidget> createState() => _NativeAdCardWidgetState();
}

class _NativeAdCardWidgetState extends State<NativeAdCardWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasFailed = false;

  bool get _isSmall => widget.size == NativeAdSize.small;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    if (!AdIds.adsEnabled || !AdIds.nativeEnabled) return;
    if (_isSmall && !AdIds.nativeSmallEnabled) return;
    if (!_isSmall && !AdIds.nativeMediumEnabled) return;

    // Platform views for AdMob native ads are supported on Android and iOS (not in unit tests)
    if (kIsWeb ||
        Platform.environment.containsKey('FLUTTER_TEST') ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }

    final adUnitId = widget.adUnitId ?? AdIds.nativeAdId;
    final factoryId = _isSmall ? 'native_small' : 'native_medium';

    try {
      _nativeAd = NativeAd(
        adUnitId: adUnitId,
        factoryId: factoryId,
        request: const AdRequest(),
        listener: NativeAdListener(
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
            debugPrint(
                '[NativeAdCardWidget (${widget.size.name})] Failed to load: $error');
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _nativeAd = null;
              _isLoaded = false;
              _hasFailed = true;
            });
          },
        ),
      );
      _nativeAd!.load();
    } catch (e) {
      debugPrint('[NativeAdCardWidget] Exception creating NativeAd: $e');
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdIds.adsEnabled || !AdIds.nativeEnabled || _hasFailed) {
      return const SizedBox.shrink();
    }

    // Heights matching the APK's exact card sizes
    final height = _isSmall ? 96.0 : 310.0;

    if (_isLoaded && _nativeAd != null) {
      return Container(
        margin: widget.margin,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }

    // High quality skeleton card mirroring ad_unit_admob_small.xml & ad_unit_admob_med.xml
    return _isSmall ? _buildSmallSkeleton() : _buildMediumSkeleton();
  }

  /// Skeleton loader for Small Native Ad (`ad_unit_admob_small.xml`)
  Widget _buildSmallSkeleton() {
    return Container(
      margin: widget.margin,
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: Row(
        children: [
          // App Icon placeholder (48x48)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppTheme.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Description Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // Green AD Badge matching APK (textColor=#0xff4caf50)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withAlpha(40),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                      ),
                      child: const Text(
                        'AD',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Install Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'INSTALL',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton loader for Medium Native Ad (`ad_unit_admob_med.xml`)
  Widget _buildMediumSkeleton() {
    return Container(
      margin: widget.margin,
      height: 310,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(20), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Icon, AD badge, and Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Green AD Badge matching APK
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withAlpha(40),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: const Color(0xFF4CAF50), width: 1),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Central 130dp MediaView area (mirrors RelativeLayout 130dp MediaView in ad_unit_admob_med.xml)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.textSecondary,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Full-width Install button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'INSTALL NOW',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
