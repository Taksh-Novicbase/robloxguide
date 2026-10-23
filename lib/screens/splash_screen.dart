import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_config.dart';
import '../features/wall_rush/screens/wall_rush_hub_screen.dart';
import '../main.dart';
import '../theme/app_theme.dart';
import '../utils/app_assets.dart';
import '../services/default_app_service.dart';
import 'default_launcher/set_default_launcher_screen.dart';
import 'home_screen.dart';
import 'launcher/launcher_home_screen.dart';
import 'launcher/widgets/app_drawer_sheet.dart';
import 'onboarding/question_screen.dart';

/// Mirrors `SplashActivity`: shows the Lottie loader, checks if the app is the
/// default home app/launcher, and routes to LauncherHomeScreen (if default launcher)
/// or HomeScreen (otherwise, prompting on first launch if not yet prompted).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  /// Reliably waits for [appState] to finish loading from SharedPreferences.
  /// Uses a listener instead of a fragile polling loop so we never miss the
  /// initialization signal, even if SharedPreferences is slow on cold start.
  Future<void> _waitForAppState() async {
    if (appState.initialized) return;

    final completer = Completer<void>();

    void listener() {
      if (appState.initialized && !completer.isCompleted) {
        completer.complete();
      }
    }

    appState.addListener(listener);

    // If it initialized between our check and adding the listener:
    if (appState.initialized && !completer.isCompleted) {
      completer.complete();
    }

    // Safety timeout — 5 seconds is generous but prevents infinite wait
    // if SharedPreferences never resolves (e.g., disk error).
    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('[SplashScreen] appState init timed out after 5s, proceeding with defaults');
      },
    );

    appState.removeListener(listener);
  }

  Future<void> _go() async {
    debugPrint('[RBX_FLOW] SplashScreen._go() started');
    try {
      unawaited(AppDrawerSheet.preload());
      await _waitForAppState();
      if (!mounted) return;

      // Wall Rush Game Guide Flow check:
      // If AppConfig.showWallRushGuide is true, display splash loader briefly,
      // show splash interstitial ad, and navigate directly to WallRushHubScreen!
      if (AppConfig.showWallRushGuide) {
        debugPrint('[RBX_FLOW] SplashScreen: AppConfig.showWallRushGuide is TRUE! Navigating to WallRushHubScreen');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WallRushHubScreen()),
        );
        return;
      }

      // Quick check: if the app is already default launcher and onboarding is pending,
      // route immediately to OnboardingFlow! (Prevents restart/delay if Android recreated task on role change)
      bool isDefault = false;
      try {
        isDefault = await DefaultAppService.isDefaultLauncher()
            .timeout(const Duration(milliseconds: 1500), onTimeout: () => false);
      } catch (e) {
        debugPrint('[RBX_FLOW] SplashScreen isDefaultLauncher error: $e');
      }

      debugPrint('[RBX_FLOW] SplashScreen check: isDefault=$isDefault, onboardingDone=${appState.onboardingDone}, settingInProgress=${appState.settingLauncherInProgress}');
      if (!mounted) return;

      if ((isDefault || appState.settingLauncherInProgress) && !appState.onboardingDone) {
        debugPrint('[RBX_FLOW] SplashScreen fast-path: Navigating directly to OnboardingFlow!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
        return;
      }

      // Normal first launch: give loader a moment to display
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      // Target selection:
      // 1. Onboarding not complete:
      //    - Not default launcher -> SetDefaultLauncherScreen
      //    - Default launcher -> OnboardingFlow
      // 2. Onboarding complete:
      //    - Default launcher -> LauncherHomeScreen(initialPage: 1)
      //    - Not default launcher -> HomeScreen() (App's home screen)
      Widget target;
      if (!appState.onboardingDone) {
        if (!isDefault) {
          debugPrint('[RBX_FLOW] SplashScreen target: SetDefaultLauncherScreen');
          target = const SetDefaultLauncherScreen();
        } else {
          debugPrint('[RBX_FLOW] SplashScreen target: OnboardingFlow');
          target = const OnboardingFlow();
        }
      } else {
        if (isDefault) {
          debugPrint('[RBX_FLOW] SplashScreen target: LauncherHomeScreen');
          target = const LauncherHomeScreen(initialPage: 1);
        } else {
          debugPrint('[RBX_FLOW] SplashScreen target: HomeScreen (app home screen when not default launcher)');
          target = const HomeScreen();
        }
      }

      // Navigate directly to target without showing any interstitial ad after splash
      if (!mounted) return;
      debugPrint('[RBX_FLOW] SplashScreen navigating to ${target.runtimeType}');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => target));
    } catch (e) {
      debugPrint('[RBX_FLOW] SplashScreen._go() error: $e');
      debugPrint('[SplashScreen] Unexpected error in _go(): $e');
      // Fallback: navigate to a safe default so the user never gets stuck
      if (!mounted) return;
      _navigateToFallback();
    }
  }

  /// Emergency fallback navigation when the normal splash flow fails.
  /// Ensures the user never gets stuck on a blank white screen.
  void _navigateToFallback() async {
    if (AppConfig.showWallRushGuide) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WallRushHubScreen()),
      );
      return;
    }

    bool isDefault = false;
    try {
      isDefault = await DefaultAppService.isDefaultLauncher()
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => false);
    } catch (_) {}
    if (!mounted) return;

    Widget target;
    if (appState.settingLauncherInProgress && !appState.onboardingDone) {
      target = const OnboardingFlow();
    } else if (!appState.onboardingDone) {
      target = !isDefault ? const SetDefaultLauncherScreen() : const OnboardingFlow();
    } else {
      target = isDefault ? const LauncherHomeScreen(initialPage: 1) : const HomeScreen();
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Lottie.asset(
          AppAssets.splashLoader,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
