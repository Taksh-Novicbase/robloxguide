import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/ad_ids.dart';
import '../../main.dart';
import '../../services/default_app_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_assets.dart';
import '../../widgets/banner_ad_widget.dart';
import '../onboarding/question_screen.dart';

/// Faithfully mirrors `SetDefaultLauncherActivity` (`activity_set_default_launcher.xml`):
/// prompts the user to configure Roblox Skins Tool as the default Home App / Launcher,
/// displaying the exact instructions, banner, tap animation, and system role trigger.
class SetDefaultLauncherScreen extends StatefulWidget {
  final bool isFromSettings;

  const SetDefaultLauncherScreen({super.key, this.isFromSettings = false});

  @override
  State<SetDefaultLauncherScreen> createState() =>
      _SetDefaultLauncherScreenState();
}

class _SetDefaultLauncherScreenState extends State<SetDefaultLauncherScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isDefault = false;
  bool _hasProceeded = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('[RBX_FLOW] SetDefaultLauncherScreen didChangeAppLifecycleState: $state, _hasProceeded=$_hasProceeded');
    if (state == AppLifecycleState.resumed && !_hasProceeded) {
      _pollForDefaultRole();
    }
  }

  Future<void> _pollForDefaultRole() async {
    debugPrint('[RBX_FLOW] Starting active polling for default launcher status...');
    for (int i = 0; i < 20; i++) {
      if (!mounted || _hasProceeded) break;
      final isDef = await DefaultAppService.isDefaultLauncher();
      debugPrint('[RBX_FLOW] Poll #$i status: isDefault = $isDef');
      if (isDef && mounted && !_hasProceeded) {
        debugPrint('[RBX_FLOW] Default launcher confirmed via poll #$i! Calling _proceed...');
        _proceed(isDefault: true);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<void> _checkStatus() async {
    if (_hasProceeded || _isChecking) return;
    _isChecking = true;
    try {
      final status = await DefaultAppService.isDefaultLauncher()
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => false);
      debugPrint('[RBX_FLOW] _checkStatus(): isDefault = $status');
      if (!mounted) return;
      setState(() => _isDefault = status);
      if (status && !widget.isFromSettings && !_hasProceeded) {
        debugPrint('[RBX_FLOW] _checkStatus() detected default, calling _proceed...');
        _proceed(isDefault: true);
      }
    } catch (e) {
      debugPrint('[RBX_FLOW] _checkStatus() error: $e');
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _handleSetAsDefault() async {
    if (_hasProceeded) return;
    debugPrint('[RBX_FLOW] User tapped SET AS DEFAULT button');
    setState(() => _isLoading = true);
    await appState.setSettingLauncherInProgress(true);
    await appState.setDefaultAppPrompted(true);

    final isSet = await DefaultAppService.requestDefaultLauncher();
    debugPrint('[RBX_FLOW] requestDefaultLauncher() returned: $isSet');
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSet) {
      debugPrint('[RBX_FLOW] requestDefaultLauncher returned true! Calling _proceed...');
      _proceed(isDefault: true);
    } else {
      debugPrint('[RBX_FLOW] requestDefaultLauncher returned false, starting polling...');
      _pollForDefaultRole();
    }
  }

  void _proceed({bool? isDefault}) async {
    debugPrint('[RBX_FLOW] _proceed() called with isDefault=$isDefault, _hasProceeded=$_hasProceeded, isFromSettings=${widget.isFromSettings}');
    if (_hasProceeded) {
      debugPrint('[RBX_FLOW] Already proceeded, ignoring duplicate call');
      return;
    }
    _hasProceeded = true;
    if (!mounted) return;

    await appState.setDefaultAppPrompted(true);
    // Keep settingLauncherInProgress true until OnboardingFlow.initState clears it.
    // This protects against process recycling / cold start while setting default launcher.

    if (widget.isFromSettings) {
      debugPrint('[RBX_FLOW] Opened from Settings, popping back');
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    // Direct, unconditional transition to OnboardingFlow as requested:
    // set default screen -> showed popup -> user seted my app -> onboarding
    debugPrint('[RBX_FLOW] >>> NAVIGATING DIRECTLY TO ONBOARDING FLOW NOW! <<<');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isFromSettings,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!widget.isFromSettings) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Setting Roblox Skins Tool as default launcher is required to continue.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
              // Top navigation (back button only when opened from Settings, skip option removed as it is required)
              if (widget.isFromSettings)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // Title: SET AS DEFAULT
                      const Text(
                        'SET AS DEFAULT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: 1.2,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle: YOUR CURRENT HOME WILL BE REPLACED
                      const Text(
                        'YOUR CURRENT HOME WILL BE REPLACED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.8,
                          color: Color(0xFF838383),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Central Illustration Card with overlay selection pill
                      _buildIllustrationCard(),

                      const SizedBox(height: 24),

                      // Description: Allows quick access to Roblox Skins Tool...
                      const Text(
                        'Allows quick access to Roblox Skins Tool from the home screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.4,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Action Button: SET AS DEFAULT
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSetAsDefault,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: AppTheme.accent.withAlpha(120),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isDefault
                                      ? 'DEFAULT APP ENABLED'
                                      : 'SET AS DEFAULT',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Instruction Footer: You can change or disable...
                      const Text(
                        'You can change or disable these features anytime from settings > Apps > Default > Apps > Home App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF838383),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom Banner Ad Container (mirrors FrameLayout id=@0x7f0900a8 banner_container)
              BannerAdWidget(adUnitId: AdIds.defaultLauncherBannerId),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildIllustrationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surface.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(25), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background graphic
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              AppAssets.image('set_default_img'),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),

          // Floating selection pill overlay (mimics the layout's RelativeLayout overlay)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _handleSetAsDefault,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // App Icon
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        AppAssets.image('default_app'),
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 38,
                          height: 38,
                          color: AppTheme.accent,
                          child: const Icon(Icons.apps, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // App Name
                    const Expanded(
                      child: Text(
                        'Roblox Skins Tool',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E202B),
                        ),
                      ),
                    ),

                    // Tap gesture animation (click.json)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Lottie.asset(
                        AppAssets.animation('click'),
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
