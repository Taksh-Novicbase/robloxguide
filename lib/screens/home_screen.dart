import 'package:flutter/material.dart';

import '../constants/ad_ids.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/ad_service.dart';
import '../services/default_app_service.dart';
import '../widgets/native_ad_card_widget.dart';
import 'converter_screen.dart';
import 'memes_screen.dart';
import 'outfit/outfit_screen.dart';
import 'quiz_screen.dart';
import 'rbx_calculator_screen.dart';
import 'redeem_screen.dart';
import 'scratch_screen.dart';
import 'spin_screen.dart';
import 'launcher/launcher_home_screen.dart';

/// Mirrors `PrimaryActivity`: the main hub with a Robux balance and three
/// tabs — "Outfit" (category browser), "Converter" (feature dashboard), and "Games & Apps".
class HomeScreen extends StatefulWidget {
  final VoidCallback? onReturnToLauncher;

  const HomeScreen({super.key, this.onReturnToLauncher});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isDefaultLauncher = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkDefaultLauncher();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDefaultLauncher();
    }
  }

  Future<void> _checkDefaultLauncher() async {
    final status = await DefaultAppService.isDefaultLauncher();
    if (mounted) {
      setState(() => _isDefaultLauncher = status);
    }
  }

  void _handleBackToLauncher() async {
    DefaultAppService.openCustomTab();
    if (widget.onReturnToLauncher != null) {
      widget.onReturnToLauncher!();
      return;
    }
    final isDefault = await DefaultAppService.isDefaultLauncher();
    if (!mounted) return;
    if (!isDefault) {
      await DefaultAppService.requestDefaultLauncher();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LauncherHomeScreen(initialPage: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canExitApp = !_isDefaultLauncher && widget.onReturnToLauncher == null;
    return PopScope(
      canPop: canExitApp,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackToLauncher();
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const TabBar(
                  labelColor: AppTheme.textPrimary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.accent,
                  labelStyle: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'Outfit'),
                    Tab(text: 'Converter'),
                    Tab(text: 'Games & Apps'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      OutfitScreen(),
                      ConverterScreen(),
                      _GamesAppsTab(),
                    ],
                  ),
                ),
                // Bottom Persistent Banner Ad (mirrors PrimaryActivity banner_container)
                BannerAdWidget(adUnitId: AdIds.homeBannerId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Back button that navigates/pops back to the launcher screen
          if (widget.onReturnToLauncher != null || _isDefaultLauncher)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _handleBackToLauncher,
              ),
            ),
          Image.asset(AppAssets.image('ic_robolox'), width: 34, height: 34),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Roblox Skins Tool',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Robux balance chip (mirrors the "RobCoins" counter).
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              return InkWell(
                onTap: () => _showCoinsDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAssets.image('ic_coins'),
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${appState.robux}',
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCoinsDialog(BuildContext context) {
    final controller = TextEditingController(text: '${appState.robux}');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Robux Balance',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Robux',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text) ?? 0;
              appState.setRobux(value);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// The 3rd tab: "Games & Apps", featuring quick interactive apps,
/// quiz, spin wheel, scratch cards, memes, and an embedded Medium Native Ad.
class _GamesAppsTab extends StatelessWidget {
  const _GamesAppsTab();

  void _openScreen(BuildContext context, Widget screen) {
    AdService.instance.showInterstitial(
      context: context,
      adUnitId: AdIds.homeInterstitialId,
      onComplete: () {
        if (!context.mounted) return;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section Header
        const Text(
          'ROBUX GAMES & TOOLS',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // 2-Column Grid of Games & Tools
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
          children: [
            _buildFeatureCard(
              title: 'Roblox Quiz',
              subtitle: 'Test your RBX knowledge',
              assetImage: AppAssets.image('ic_quiz'),
              badge: 'QUIZ',
              onTap: () => _openScreen(context, const QuizScreen()),
            ),
            _buildFeatureCard(
              title: 'Spin & Win',
              subtitle: 'Spin daily lucky wheel',
              assetImage: AppAssets.image('ic_spin'),
              badge: 'REWARD',
              onTap: () => _openScreen(context, const SpinScreen()),
            ),
            _buildFeatureCard(
              title: 'Scratch Card',
              subtitle: 'Scratch to reveal Robux',
              assetImage: AppAssets.image('ic_scratch'),
              badge: 'LUCKY',
              onTap: () => _openScreen(context, const ScratchScreen()),
            ),
            _buildFeatureCard(
              title: 'Daily Calculator',
              subtitle: 'Calculate daily free RBX',
              assetImage: AppAssets.image('comman_cal_img'),
              badge: 'CALC',
              onTap: () => _openScreen(context, const RbxCalculatorScreen()),
            ),
            _buildFeatureCard(
              title: 'Roblox Memes',
              subtitle: 'Top funny Roblox memes',
              assetImage: AppAssets.image('ic_memes'),
              badge: 'FUN',
              onTap: () => _openScreen(context, const MemesScreen()),
            ),
            _buildFeatureCard(
              title: 'Redeem Code',
              subtitle: 'Claim reward points',
              assetImage: AppAssets.image('ic_redeem'),
              badge: 'CODE',
              onTap: () => _openScreen(context, const RedeemScreen()),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Medium Native Ad Placement
        MediumNativeAdWidget(adUnitId: AdIds.homeNativeId),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String assetImage,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(20), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    assetImage,
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.videogame_asset_rounded,
                      color: AppTheme.accent,
                      size: 32,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppTheme.accent.withAlpha(120),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
