import 'package:flutter/material.dart';

import '../../../constants/ad_ids.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_assets.dart';
import '../../../widgets/native_ad_card_widget.dart';
import '../../converter_screen.dart';
import '../../home_screen.dart';
import '../../quiz_screen.dart';
import '../../rbx_calculator_screen.dart';
import '../../scratch_screen.dart';
import '../../spin_screen.dart';

/// Screen displayed when user swipes right from the Home Screen,
/// mirroring `activity_right_side.xml` ("Widgets & Other Apps").
class WidgetsScreen extends StatelessWidget {
  final VoidCallback onReturnHome;

  const WidgetsScreen({
    super.key,
    required this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Widgets & Tools',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withAlpha(180),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Swipe right to return to Home',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onReturnHome,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Feature Card 1: Roblox Skins Tool Hub
              _buildFeatureCard(
                title: 'Roblox Skins & Outfits',
                subtitle: 'Browse Emotes, Shirts, Pants & Bundles',
                icon: AppAssets.image('app_icon'),
                badge: 'FEATURED',
                gradient: const [Color(0xFF2C1948), Color(0xFF17122B)],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Feature Card 2: Daily Robux Calculator
              _buildFeatureCard(
                title: 'Daily Robux Calculator',
                subtitle: 'Calculate your daily free Robux estimation',
                icon: AppAssets.image('comman_cal_img'),
                badge: 'CALCULATOR',
                gradient: const [Color(0xFF1A334B), Color(0xFF101D2C)],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RbxCalculatorScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Static Native Ad (mirrors `@+id/native_ad_container` in `activity_right_side.xml`)
              MediumNativeAdWidget(
                margin: const EdgeInsets.symmetric(vertical: 8),
                adUnitId: AdIds.launcherNativeId,
              ),

              const SizedBox(height: 16),

              // Other Apps / Quick Tools Section Header
              const Text(
                'QUICK APPS & GAMES',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // 4-Column Quick Tools Grid
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickToolIcon(
                      title: 'Quiz',
                      assetImage: AppAssets.image('ic_quiz'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      ),
                    ),
                    _buildQuickToolIcon(
                      title: 'Spin',
                      assetImage: AppAssets.image('ic_spin'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SpinScreen()),
                      ),
                    ),
                    _buildQuickToolIcon(
                      title: 'Scratch',
                      assetImage: AppAssets.image('ic_scratch'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ScratchScreen()),
                      ),
                    ),
                    _buildQuickToolIcon(
                      title: 'Convert',
                      assetImage: AppAssets.image('ic_converter'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ConverterScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String icon,
    required String badge,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withAlpha(35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                icon,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 52,
                  height: 52,
                  color: AppTheme.accent,
                  child: const Icon(Icons.star, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolIcon({
    required String title,
    required String assetImage,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withAlpha(30),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              assetImage,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.apps_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
