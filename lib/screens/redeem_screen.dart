import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_card_widget.dart';

/// Mirrors `RedeemCoinActivity`: redeem saved coins for rewards, checking
/// the balance first ("You Don't have enough coins").
class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  static const List<_RedeemOption> _options = [
    _RedeemOption(
      label: '100 Robux',
      cost: 1000,
      reward: 100,
      icon: 'redeem_ser1',
    ),
    _RedeemOption(
      label: '500 Robux',
      cost: 4000,
      reward: 500,
      icon: 'redeem_ser2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Redeem Coins'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final o in _options) _buildCard(context, o),
                  const SizedBox(height: 12),
                  // Medium Native Ad Placement with MediaView (mirrors activity_redeem_coin.xml native_container)
                  MediumNativeAdWidget(adUnitId: AdIds.toolsNativeId),

                ],
              ),
            ),
            // Bottom Banner Ad Container (mirrors activity_redeem_coin.xml banner_container)
            BannerAdWidget(adUnitId: AdIds.toolsBannerId),
          ],
        ),
      ),
    );
  }


  Widget _buildCard(BuildContext context, _RedeemOption option) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/${option.icon}.webp',
                width: 64,
                height: 64,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.card_giftcard,
                  color: AppTheme.textSecondary,
                  size: 48,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${option.cost} coins',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _redeem(context, option),
                child: const Text('Redeem'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _redeem(BuildContext context, _RedeemOption option) {
    if (appState.robux < option.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You Don't have enough coins")),
      );
      return;
    }
    appState.setRobux(appState.robux - option.cost);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redeemed ${option.reward} Robux!')),
    );
  }
}

class _RedeemOption {
  final String label;
  final int cost;
  final int reward;
  final String icon;

  const _RedeemOption({
    required this.label,
    required this.cost,
    required this.reward,
    required this.icon,
  });
}
