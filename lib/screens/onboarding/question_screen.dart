import 'package:flutter/material.dart';

import '../../constants/ad_ids.dart';
import '../../main.dart';
import '../../services/ad_service.dart';
import '../../services/default_app_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_assets.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_card_widget.dart';
import '../default_launcher/set_default_launcher_screen.dart';
import '../home_screen.dart';
import 'onboarding_steps.dart';

/// The complete Onboarding questionnaire flow (9 question steps + StartScreen "You're All Set!")
/// fulfilling user requirements:
/// 1. When app is configured as default launcher, arriving in the app requires completing onboarding first.
/// 2. User can back to home screen only ("user can back in home screen only").
/// 3. User cannot back inside the onboarding questionnaire ("not in onboard").
/// 4. Onboarding is strictly required before the app can be accessed ("required to complet onboard").
/// 5. Exact ad placements matching the reference video:
///    - Small and Medium Native Ads embedded according to each step's layout
///    - Interstitial ad on every step transition and on Start App
///    - Bottom banner ads where specified
class OnboardingFlow extends StatefulWidget {
  final int initialStep;
  final VoidCallback? onReturnToLauncher;
  final VoidCallback? onCompleted;

  const OnboardingFlow({
    super.key,
    this.initialStep = 0,
    this.onReturnToLauncher,
    this.onCompleted,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with WidgetsBindingObserver {
  late int _stepIndex;
  int? _selected;
  bool _isAdvancing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('[RBX_FLOW] >>> ARRIVED IN ONBOARDING FLOW! <<< (initialStep=${widget.initialStep})');
    appState.setSettingLauncherInProgress(false);
    WidgetsBinding.instance.addObserver(this);
    _stepIndex = widget.initialStep;
    _selected = 0; // Default select first item for seamless UX
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset any pending advancement flags so buttons are always clickable immediately on arrival
      _isAdvancing = false;
      if (!AdService.instance.isAdShowing) {
        _isSubmitting = false;
      }
      DefaultAppService.openedFromOnboarding = false;
    }
  }

  void _openCustomTab() {
    DefaultAppService.openedFromOnboarding = true;
    DefaultAppService.openCustomTab(null, true);
  }

  void _handleBack() {
    _isAdvancing = false;
    _isSubmitting = false;
    _openCustomTab();
    if (_stepIndex > 0) {
      setState(() {
        _stepIndex--;
        _selected = 0;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      return;
    }
    if (widget.onReturnToLauncher != null) {
      widget.onReturnToLauncher!();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
      return;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetDefaultLauncherScreen()),
      );
      return;
    }
  }

  void _advanceStep() {
    if (_selected == null || _isAdvancing) return;
    _isAdvancing = true;

    bool hasProceeded = false;
    void proceed() {
      if (hasProceeded) return;
      hasProceeded = true;
      _isAdvancing = false;
      if (!mounted) return;
      setState(() {
        _stepIndex++;
        _selected = 0;
      });
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }

    // Step 2 ("Choose Your Outfit"): 1st App Open Ad
    // Step 4 ("Pick Your Surprise"): 1 Rewarded Ad
    // Step 6 ("What Content Do You Like ?"): 2nd App Open Ad
    // Other steps: Interstitial Ads (place maintained)
    if (_stepIndex == 2) {
      AdService.instance.showAppOpenAd(
        adUnitId: AdIds.onboardingAppOpenId,
        onComplete: proceed,
      );
    } else if (_stepIndex == 4) {
      AdService.instance.showRewardedAd(
        context: context,
        adUnitId: AdIds.onboardingRewardedId,
        onComplete: proceed,
      );
    } else if (_stepIndex == 6) {
      AdService.instance.showAppOpenAd(
        adUnitId: AdIds.onboardingAppOpenId,
        onComplete: proceed,
      );
    } else {
      AdService.instance.showInterstitial(
        context: context,
        ignoreCooldown: true,
        adUnitId: AdIds.onboardingInterstitialId,
        onComplete: proceed,
      );
    }
  }

  bool _isSubmitting = false;

  void _handleStartApp() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    bool hasProceeded = false;
    final navigator = Navigator.of(context);

    Future<void> proceedToApp() async {
      if (hasProceeded) return;
      hasProceeded = true;
      try {
        await appState.completeOnboarding();

        if (widget.onCompleted != null) {
          try {
            widget.onCompleted!();
          } catch (e) {
            debugPrint('[OnboardingFlow] onCompleted callback: $e');
          }
        }

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } catch (e) {
        debugPrint('[OnboardingFlow] Navigation error: $e');
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
        onComplete: proceedToApp,
      );
    } catch (e) {
      debugPrint('[OnboardingFlow] showInterstitial error: $e');
      await proceedToApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[RBX_FLOW] OnboardingFlow.build() called for step: $_stepIndex');
    // If all 9 steps completed, render step 9: StartScreen ("You're All Set!")
    final isFinalStep = _stepIndex >= onboardingSteps.length;
    final step = !isFinalStep ? onboardingSteps[_stepIndex] : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Navigation constraint: back press returns to Home Screen only, not back within onboarding
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
                if (!isFinalStep)
                  _buildHeader(step!)
                else
                  _buildFinalStepHeader(),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: !isFinalStep
                        ? _buildStepBody(step!)
                        : _buildStartScreenBody(),
                  ),
                ),

                if (!isFinalStep)
                  _buildBottomSection(step!)
                else
                  _buildFinalStepActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(QuestionStep step) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: InkWell(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.onReturnToLauncher != null && _stepIndex == 0
                          ? Icons.home_rounded
                          : Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.onReturnToLauncher != null && _stepIndex == 0
                          ? 'Home'
                          : 'Back',
                      style: const TextStyle(
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
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Progress step indicator e.g. 1/9
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accent.withAlpha(100),
                width: 1,
              ),
            ),
            child: Text(
              '${_stepIndex + 1}/${onboardingSteps.length}',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStepHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.onReturnToLauncher != null
                        ? Icons.home_rounded
                        : Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.onReturnToLauncher != null
                        ? 'Home Screen'
                        : 'Back',
                    style: const TextStyle(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accent.withAlpha(100),
                width: 1,
              ),
            ),
            child: const Text(
              'Complete',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBody(QuestionStep step) {
    switch (step.layoutType) {
      case StepLayoutType.style:
        return _buildStyleLayout(step);
      case StepLayoutType.vibe:
        return _buildVibeLayout(step);
      case StepLayoutType.outfit:
        return _buildOutfitLayout(step);
      case StepLayoutType.calculator:
        return _buildCalculatorLayout(step);
      case StepLayoutType.surprise:
        return _buildSurpriseLayout(step);
      case StepLayoutType.avatarType:
        return _buildAvatarTypeLayout(step);
      case StepLayoutType.contentLike:
        return _buildContentLikeLayout(step);
      case StepLayoutType.challengeMode:
        return _buildChallengeModeLayout(step);
      case StepLayoutType.wantMost:
        return _buildWantMostLayout(step);
    }
  }

  // 1. Style Layout: Top Small Native Ad + 4 cards grid + Bottom Medium Native Ad
  Widget _buildStyleLayout(QuestionStep step) {
    return Column(
      children: [
        SmallNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (int i = 0; i < step.options.length; i++)
                _buildCardOption(step.options[i], i),
            ],
          ),
        ),
        _buildActionButton(step),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
      ],
    );
  }

  // 2. Vibe Layout: List of options + Next button + Bottom Medium Native Ad
  Widget _buildVibeLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (int i = 0; i < step.options.length; i++) ...[
                _buildListOption(step.options[i], i),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        _buildActionButton(step),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
      ],
    );
  }

  // 3. Choose Outfit Layout: Row 1 (2 items) + Medium Native Ad + Go Ahead button + Row 2 (2 items) + Bottom Banner
  Widget _buildOutfitLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildCardOption(step.options[0], 0)),
              const SizedBox(width: 12),
              Expanded(child: _buildCardOption(step.options[1], 1)),
            ],
          ),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        _buildActionButton(step),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(child: _buildCardOption(step.options[2], 2)),
              const SizedBox(width: 12),
              Expanded(child: _buildCardOption(step.options[3], 3)),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Calculator Layout: Top Small Native Ad + 4 items + Continue button + Bottom Banner
  Widget _buildCalculatorLayout(QuestionStep step) {
    return Column(
      children: [
        SmallNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (int i = 0; i < step.options.length; i++) ...[
                _buildListOption(step.options[i], i),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        _buildActionButton(step),
      ],
    );
  }

  // 5. Surprise Layout: 2 cards + Medium Native Ad + Continue button
  Widget _buildSurpriseLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < step.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _buildCardOption(step.options[i], i)),
              ],
            ],
          ),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        _buildActionButton(step),
      ],
    );
  }

  // 6. Avatar Type: Item 1 (Boy) + Medium Native Ad + Items 2 & 3 (Girl, Both) + Continue button
  Widget _buildAvatarTypeLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildListOption(step.options[0], 0),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (int i = 1; i < step.options.length; i++) ...[
                _buildListOption(step.options[i], i),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        _buildActionButton(step),
      ],
    );
  }

  // 7. Content Like: Row 1 (3 items) + Medium Native Ad + Continue button + Row 2 (3 items)
  Widget _buildContentLikeLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _buildCompactCard(step.options[i], i)),
              ],
            ],
          ),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        _buildActionButton(step),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              for (int i = 3; i < step.options.length; i++) ...[
                if (i > 3) const SizedBox(width: 8),
                Expanded(child: _buildCompactCard(step.options[i], i)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 8. Challenge Mode: Items 0-2 + Medium Native Ad + Next button + Item 3 + Bottom Banner
  Widget _buildChallengeModeLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (int i = 0; i < 3; i++) ...[
                _buildListOption(step.options[i], i),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        _buildActionButton(step),
        if (step.options.length > 3)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildListOption(step.options[3], 3),
          ),
      ],
    );
  }

  // 9. Want Most: 4 cards grid + Medium Native Ad + Go Ahead button
  Widget _buildWantMostLayout(QuestionStep step) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              for (int i = 0; i < step.options.length; i++)
                _buildCardOption(step.options[i], i),
            ],
          ),
        ),
        MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        _buildActionButton(step),
      ],
    );
  }

  // Final Step 9: "You're All Set!" Body (matching frame 01:12)
  Widget _buildStartScreenBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 10),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBadge(Icons.palette_outlined, 'Design'),
              _buildBadge(Icons.quiz_outlined, 'Quiz'),
              _buildBadge(Icons.card_giftcard_outlined, 'Rewards'),
              _buildBadge(Icons.widgets_outlined, 'More'),
            ],
          ),
          const SizedBox(height: 14),
          MediumNativeAdWidget(adUnitId: AdIds.onboardingNativeId),
        ],
      ),
    );
  }

  Widget _buildFinalStepActionButton() {
    return Padding(
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
                    Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                  ],
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

  // Card Tile (Grid 2-col)
  Widget _buildCardOption(QuestionOption option, int index) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () {
        _openCustomTab();
        setState(() => _selected = index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardSelected : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.white.withAlpha(20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  AppAssets.image(option.iconAsset),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.textSecondary,
                    size: 40,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact Card (Grid 3-col)
  Widget _buildCompactCard(QuestionOption option, int index) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () {
        _openCustomTab();
        setState(() => _selected = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardSelected : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.white.withAlpha(20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              AppAssets.image(option.iconAsset),
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.star_outline,
                color: AppTheme.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              option.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // List Option Tile (Horizontal card with icon, title, subtitle & radio)
  Widget _buildListOption(QuestionOption option, int index) {
    final isSelected = _selected == index;
    return GestureDetector(
      onTap: () {
        _openCustomTab();
        setState(() => _selected = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.cardSelected : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.white.withAlpha(20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              AppAssets.image(option.iconAsset),
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.check_circle_outline,
                color: AppTheme.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // Continue / Next / Go Ahead Button
  Widget _buildActionButton(QuestionStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _selected == null ? null : _advanceStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                step.buttonLabel,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Banner Ad where appropriate
  Widget _buildBottomSection(QuestionStep step) {
    if (step.layoutType == StepLayoutType.outfit ||
        step.layoutType == StepLayoutType.calculator ||
        step.layoutType == StepLayoutType.challengeMode) {
      return BannerAdWidget(adUnitId: AdIds.onboardingBannerId);
    }
    return const SizedBox.shrink();
  }
}

/// Compatibility wrapper for QuestionScreen
class QuestionScreen extends StatelessWidget {
  final int stepIndex;
  final VoidCallback? onReturnToLauncher;

  const QuestionScreen({
    super.key,
    this.stepIndex = 0,
    this.onReturnToLauncher,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingFlow(
      initialStep: stepIndex,
      onReturnToLauncher: onReturnToLauncher,
    );
  }
}
