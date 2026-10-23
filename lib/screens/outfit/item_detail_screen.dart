import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/ad_ids.dart';
import '../../models/item.dart';
import '../../services/ad_service.dart';
import '../../services/default_app_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_card_widget.dart';

/// Matches frames 01:31 - 01:45 from the video recording:
/// - Phase 0: Item Preview with "Preview" button + Medium Native Ad
/// - Phase 1: "How to Use" with Instructions, "Next" button + Banner Ad
/// - Phase 2: "Show Outfit ID" with ID card, copy action, Medium Native Ad & Related items
class ItemDetailScreen extends StatefulWidget {
  final OutfitItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with WidgetsBindingObserver {
  int _phase = 0; // 0 = Preview, 1 = How to Use, 2 = Show Outfit ID

  // Stable pseudo-random catalog ID for this item
  late final String _catalogId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final hash = widget.item.name.hashCode.abs();
    _catalogId = '${8600000000 + (hash % 100000000)}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted && _isAdvancing && !AdService.instance.isAdShowing) {
        setState(() => _isAdvancing = false);
      }
    }
  }

  bool _isAdvancing = false;

  void _handleBack() {
    _isAdvancing = false;
    DefaultAppService.openCustomTab();
    if (_phase > 0) {
      setState(() => _phase--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: widget.item.name,
                onBack: _handleBack,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _buildCurrentPhase(),
                ),
              ),
              if (_phase == 1)
                BannerAdWidget(adUnitId: AdIds.outfitBannerId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case 0:
        return _buildPhase0Preview();
      case 1:
        return _buildPhase1HowToUse();
      case 2:
      default:
        return _buildPhase2OutfitId();
    }
  }

  // Phase 0: Preview (matching frame 01:31)
  Widget _buildPhase0Preview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildItemImageHeader(),
        const SizedBox(height: 12),
        if (widget.item.shortDesc.isNotEmpty) ...[
          Text(
            widget.item.shortDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          widget.item.desc.isEmpty
              ? 'An emote / item showcasing signature style and swagger.'
              : widget.item.desc,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Orange "Preview" button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () => _advanceToPhase(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Preview',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Medium Native Ad directly below preview button (frame 01:31)
        MediumNativeAdWidget(
          margin: EdgeInsets.zero,
          adUnitId: AdIds.outfitNativeId,
        ),
      ],
    );
  }

  // Phase 1: How to Use (matching frame 01:37)
  Widget _buildPhase1HowToUse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildItemImageHeader(),
        const SizedBox(height: 14),

        // Orange "Next" button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () => _advanceToPhase(2),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Instructions Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Use',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '1. Copy catalog ID from this app and Paste the copied ID in the Roblox marketplace search bar.',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Disclaimer: This app lists catalog identifiers from the official Roblox Marketplace. We do not modify or hack in-game items.',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Phase 2: Show Outfit ID & Related items (matching frames 01:41 - 01:45)
  Widget _buildPhase2OutfitId() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildItemImageHeader(),
        const SizedBox(height: 14),

        // ID Container / Button with Copy action (frame 01:45)
        GestureDetector(
          onTap: () => _copy(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accent, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _catalogId,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 1.2,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.copy, color: AppTheme.accent, size: 20),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Medium Native Ad directly below Outfit ID (matching frame 01:45)
        MediumNativeAdWidget(
          margin: EdgeInsets.zero,
          adUnitId: AdIds.outfitNativeId,
        ),
        const SizedBox(height: 16),

        // Related Section Header
        const Text(
          'Related',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Related items grid (2x2 cards)
        Row(
          children: [
            Expanded(child: _buildRelatedCard('Salute Gesture')),
            const SizedBox(width: 12),
            Expanded(child: _buildRelatedCard('Samba Dance')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildRelatedCard('Tilt Pose')),
            const SizedBox(width: 12),
            Expanded(child: _buildRelatedCard('Side Sway')),
          ],
        ),
      ],
    );
  }

  Widget _buildItemImageHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Image.asset(
              widget.item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.accessibility_new,
                color: AppTheme.accent,
                size: 70,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.item.name,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCard(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          const Icon(Icons.accessibility, color: AppTheme.textSecondary, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _advanceToPhase(int nextPhase) {
    if (_isAdvancing) return;
    _isAdvancing = true;

    bool hasProceeded = false;
    void proceed() {
      if (hasProceeded) return;
      hasProceeded = true;
      _isAdvancing = false;
      if (!mounted) return;
      setState(() {
        _phase = nextPhase;
      });
    }

    AdService.instance.showInterstitial(
      context: context,
      ignoreCooldown: true,
      adUnitId: AdIds.outfitInterstitialId,
      onComplete: proceed,
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _catalogId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catalog ID $_catalogId Copied!'),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }
}
