import 'package:flutter/material.dart';

import '../../constants/ad_ids.dart';
import '../../main.dart';
import '../../services/ad_service.dart';
import '../../services/default_app_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_assets.dart';
import '../../widgets/native_ad_card_widget.dart';
import '../home_screen.dart';

/// Matches frame 01:12 from the video recording: "You're All Set!"
/// Displays character artwork, feature badges, a Medium Native Ad,
/// and the "Start App" button with an on-transition Interstitial ad.
/// Strictly enforces launcher navigation: back press returns to home screen only.
class StartScreen extends StatefulWidget {
  final VoidCallback? onReturnToLauncher;
  final VoidCallback? onStartApp;

  const StartScreen({super.key, this.onReturnToLauncher, this.onStartApp});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with WidgetsBindingObserver {
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      DefaultAppService.openedFromOnboarding = false;
      if (mounted && _isSubmitting && !AdService.instance.isAdShowing) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _openCustomTab() {
    DefaultAppService.openedFromOnboarding = true;
    DefaultAppService.openCustomTab(null, true);
  }

  void _handleBack() {
    _isSubmitting = false;
    _openCustomTab();
    if (widget.onReturnToLauncher != null) {
      widget.onReturnToLauncher!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  void _handleStartApp() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    bool hasProceeded = false;
    final navigator = Navigator.of(context);
    Future<void> proceed() async {
      if (hasProceeded) return;
      hasProceeded = true;
      try {
        await appState.completeOnboarding();
        if (widget.onStartApp != null) {
          try {
            widget.onStartApp!();
          } catch (_) {}
        }
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        debugPrint('[StartScreen] Navigation error: $e');
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }

    try {
      AdService.instance.showInterstitial(
        context: context,
        ignoreCooldown: true,
        adUnitId: AdIds.onboardingInterstitialId,
        onComplete: proceed,
      );
    } catch (e) {
      proceed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/main_bg.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Header with optional return to home launcher button
                if (widget.onReturnToLauncher != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _handleBack,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withAlpha(30),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Home Screen',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Character Artwork (ic_start)
                        GestureDetector(
                          onTap: _openCustomTab,
                          child: Center(
                            child: Image.asset(
                              AppAssets.image('ic_start'),
                              width: 170,
                              height: 170,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "You're All Set!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Your style journey is ready. Let's explore and create amazing outfits!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 4 quick feature badges (Design, Quiz, Rewards, More)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBadge(Icons.palette_outlined, 'Design'),
                            _buildBadge(Icons.quiz_outlined, 'Quiz'),
                            _buildBadge(
                              Icons.card_giftcard_outlined,
                              'Rewards',
                            ),
                            _buildBadge(Icons.widgets_outlined, 'More'),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Medium Native Ad placement (matching frame 01:12)
                        MediumNativeAdWidget(
                          adUnitId: AdIds.onboardingNativeId,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Start App Action Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleStartApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start App',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return GestureDetector(
      onTap: _openCustomTab,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
