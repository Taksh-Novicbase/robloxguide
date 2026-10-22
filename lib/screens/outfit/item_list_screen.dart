import 'package:flutter/material.dart';

import '../../constants/ad_ids.dart';
import '../../models/item.dart';
import '../../services/ad_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/native_ad_card_widget.dart';
import 'item_detail_screen.dart';

/// Matches frame 01:25 - 01:27 from the video recording:
/// - 2-column grid of items
/// - Bottom Medium Native Ad
/// - On-transition Interstitial ad when selecting any item
class ItemListScreen extends StatelessWidget {
  final ItemCategory category;

  const ItemListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: category.title),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: category.items.length,
                        itemBuilder: (context, i) {
                          final item = category.items[i];
                          return _ItemCard(
                            item: item,
                            onTap: () {
                              AdService.instance.showInterstitial(
                                context: context,
                                ignoreCooldown: true,
                                adUnitId: AdIds.outfitInterstitialId,
                                onComplete: () {
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ItemDetailScreen(item: item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Bottom Medium Native Ad placement (matching frame 01:25 - 01:27)
                    MediumNativeAdWidget(adUnitId: AdIds.outfitNativeId),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final OutfitItem item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                item.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.accessibility,
                  color: AppTheme.accent,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
