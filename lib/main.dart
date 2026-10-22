import 'package:flutter/material.dart';

import 'screens/onboarding/question_screen.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

import 'services/ad_service.dart';
import 'services/default_app_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[RBX_FLOW] main() started');
  // Initialize app state from SharedPreferences immediately
  await appState.init();
  debugPrint('[RBX_FLOW] appState initialized: onboardingDone=${appState.onboardingDone}, settingLauncherInProgress=${appState.settingLauncherInProgress}');
  // Initialize Google Mobile Ads SDK and start precaching/preloading ads
  await AdService.instance.init();

  // If the user just configured default launcher or if role is held and onboarding is pending,
  // launch directly into OnboardingFlow without showing SplashScreen or restarting delay!
  Widget initialScreen = const SplashScreen();
  if (appState.settingLauncherInProgress && !appState.onboardingDone) {
    debugPrint('[RBX_FLOW] main(): settingLauncherInProgress is true! Initializing directly on OnboardingFlow');
    initialScreen = const OnboardingFlow();
  } else if (!appState.onboardingDone) {
    try {
      final isDefault = await DefaultAppService.isDefaultLauncher()
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => false);
      debugPrint('[RBX_FLOW] main(): isDefault=$isDefault, onboardingDone=${appState.onboardingDone}');
      if (isDefault) {
        debugPrint('[RBX_FLOW] main(): isDefault is true and onboarding pending! Initializing directly on OnboardingFlow');
        initialScreen = const OnboardingFlow();
      }
    } catch (e) {
      debugPrint('[RBX_FLOW] main(): error checking default: $e');
    }
  }

  debugPrint('[RBX_FLOW] main(): rendering RbxSkinsToolApp with initialScreen: ${initialScreen.runtimeType}');
  runApp(RbxSkinsToolApp(initialScreen: initialScreen));
}

class RbxSkinsToolApp extends StatelessWidget {
  final Widget initialScreen;

  const RbxSkinsToolApp({
    super.key,
    this.initialScreen = const SplashScreen(),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roblox Skins Tool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      navigatorObservers: [
        _CustomTabNavigationObserver(),
      ],
      home: initialScreen,
    );
  }
}

/// Automatically launches custom tab when any screen/route is popped via system or in-app back navigation
class _CustomTabNavigationObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (appState.onboardingDone && DefaultAppService.isLauncherActiveState) {
      DefaultAppService.openCustomTab();
    }
  }
}

/// Global app state (Robux balance, onboarding flag, etc.).
final AppState appState = AppState();
