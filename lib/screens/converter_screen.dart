import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../data/app_repository.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_tile.dart';
import '../widgets/native_ad_card_widget.dart';
import 'memes_screen.dart';
import 'quiz_screen.dart';
import 'rbx_calculator_screen.dart';
import 'redeem_screen.dart';
import 'scratch_screen.dart';
import 'settings_screen.dart';
import 'spin_screen.dart';

/// The "Converter" tab: a dashboard of currency conversions and the other
/// app features (mirrors the converter hub reachable from `PrimaryActivity`).
class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Currency Converters'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            for (final c in AppRepository.conversions)
              FeatureTile(
                label: c.title,
                iconAsset: c.icon,
                onTap: () {
                  AdService.instance.showInterstitial(
                    context: context,
                    adUnitId: AdIds.toolsInterstitialId,
                    onComplete: () {
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RbxCalculatorScreen(conversion: c),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Medium Native Ad Placement with MediaView (mirrors fragment_rbx_converter.xml native_container)
        MediumNativeAdWidget(adUnitId: AdIds.toolsNativeId),


        const SizedBox(height: 16),
        const _SectionTitle('More Tools'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            FeatureTile(
              label: 'Logic Quiz',
              iconAsset: 'ic_quiz',
              onTap: () => _push(context, const QuizScreen()),
            ),
            FeatureTile(
              label: 'Spin Wheel',
              iconAsset: 'ic_spin',
              onTap: () => _push(context, const SpinScreen()),
            ),
            FeatureTile(
              label: 'Memes',
              iconAsset: 'ic_memes',
              onTap: () => _push(context, const MemesScreen()),
            ),
            FeatureTile(
              label: 'Redeem',
              iconAsset: 'ic_redeem',
              onTap: () => _push(context, const RedeemScreen()),
            ),
            FeatureTile(
              label: 'Scratch',
              iconAsset: 'ic_scratch',
              onTap: () => _push(context, const ScratchScreen()),
            ),
            FeatureTile(
              label: 'Settings',
              iconAsset: 'ic_setting',
              onTap: () => _push(context, const SettingsScreen()),
            ),
          ],
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget screen) {
    AdService.instance.showInterstitial(
      context: context,
      adUnitId: AdIds.toolsInterstitialId,
      onComplete: () {
        if (!context.mounted) return;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
