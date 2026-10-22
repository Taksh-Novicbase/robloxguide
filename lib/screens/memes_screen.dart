import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../data/app_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';

/// Mirrors `MemeActivity`: a scrolling list of memes (title + body).
class MemesScreen extends StatelessWidget {
  const MemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Memes For Fun'),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: AppRepository.memes.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  // Insert Small Native Ad into the meme list (mirrors activity_meme.xml native_container)
                  if (i == 1) {
                    return SmallNativeAdWidget(adUnitId: AdIds.toolsNativeId);
                  }

                  final memeIndex = i > 1 ? i - 1 : i;
                  if (memeIndex >= AppRepository.memes.length) {
                    return const SizedBox.shrink();
                  }
                  final meme = AppRepository.memes[memeIndex];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meme.title,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meme.body,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            height: 1.4,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Banner Ad
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }
}

