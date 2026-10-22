import 'package:flutter/material.dart';

import '../../constants/ad_ids.dart';
import '../../data/app_repository.dart';
import '../../models/item.dart';
import '../../services/ad_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_assets.dart';
import '../../widgets/native_ad_card_widget.dart';
import 'item_list_screen.dart';

/// Matches frame 01:15 - 01:22 from the video recording:
/// - Top "All Emotes Animation" banner
/// - Medium Native Ad directly below the banner
/// - 2-column grid of clothing & skin categories
/// - On-transition Interstitial ad when navigating to item list
class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

class _OutfitScreenState extends State<OutfitScreen> {
  late Future<List<ItemCategory>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppRepository.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemCategory>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accent),
          );
        }
        final categories = snapshot.data ?? const <ItemCategory>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // "All Emotes Animation" Banner Button (matching frame 01:15)
              _buildAllEmotesBanner(categories),

              const SizedBox(height: 12),

              // Medium Native Ad Placement directly below the banner (matching frame 01:15)
              MediumNativeAdWidget(
                margin: const EdgeInsets.symmetric(vertical: 4),
                adUnitId: AdIds.outfitNativeId,
              ),

              const SizedBox(height: 12),

              // 2-column grid of categories (matching frame 01:16)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  return _buildCategoryCard(cat);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Top "All Emotes Animation" banner with dancer icon matching video
  Widget _buildAllEmotesBanner(List<ItemCategory> categories) {
    return GestureDetector(
      onTap: () {
        // Find emotes category or fall back to first category
        final emotesCat = categories.firstWhere(
          (c) => c.title.toLowerCase().contains('emote'),
          orElse: () => categories.isNotEmpty
              ? categories.first
              : const ItemCategory(title: 'Emotes', items: []),
        );

        AdService.instance.showInterstitial(
          context: context,
          ignoreCooldown: true,
          adUnitId: AdIds.outfitInterstitialId,
          onComplete: () {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemListScreen(category: emotesCat),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A2B), // Dark green tone matching video
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4CAF50).withAlpha(100), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                AppAssets.image('ic_emotes'),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.accessibility_new,
                  color: Color(0xFF4CAF50),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'All Emotes Animation',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(ItemCategory category) {
    return GestureDetector(
      onTap: () {
        AdService.instance.showInterstitial(
          context: context,
          ignoreCooldown: true,
          adUnitId: AdIds.outfitInterstitialId,
          onComplete: () {
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemListScreen(category: category),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                category.previewPath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.checkroom,
                  color: AppTheme.accent,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
