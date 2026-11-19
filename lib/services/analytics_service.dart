import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Dedicated Firebase Analytics Service for Roblox Skins Tool.
/// Specifically configured to log ONLY the Onboarding screen events (steps 1 to 9 & start screen).
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalytics get analytics => _analytics;

  /// Log screen view and custom event when an onboarding step screen is shown.
  /// [stepIndex]: 0-based index (0 to 8 = Steps 1 to 9, >=9 = Start Screen).
  Future<void> logOnboardingScreenView({
    required int stepIndex,
    required String stepTitle,
  }) async {
    final screenNumber = stepIndex + 1;
    final screenName = stepIndex < 9
        ? 'onboarding_screen_$screenNumber'
        : 'onboarding_start_screen';

    try {
      // 1. Standard screen view log
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: 'OnboardingFlow',
      );

      // 2. Custom step-specific event
      final eventName = stepIndex < 9
          ? 'onboarding_screen_${screenNumber}_view'
          : 'onboarding_start_screen_view';

      await _analytics.logEvent(
        name: eventName,
        parameters: {
          'step_number': screenNumber,
          'step_title': stepTitle,
        },
      );

      // Standard first step tracking
      if (stepIndex == 0) {
        await _analytics.logTutorialBegin();
      }

      debugPrint('[Analytics] Logged $screenName ($eventName): $stepTitle');
    } catch (e) {
      debugPrint('[Analytics] logOnboardingScreenView error: $e');
    }
  }

  /// Log action when user answers / clicks Next on an onboarding step screen.
  Future<void> logOnboardingStepNext({
    required int stepIndex,
    required String stepTitle,
    required int selectedIndex,
    required String selectedOption,
  }) async {
    final screenNumber = stepIndex + 1;
    final eventName = 'onboarding_screen_${screenNumber}_next';

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: {
          'step_number': screenNumber,
          'step_title': stepTitle,
          'selected_index': selectedIndex,
          'selected_option': selectedOption,
        },
      );
      debugPrint('[Analytics] Logged $eventName: $selectedOption');
    } catch (e) {
      debugPrint('[Analytics] logOnboardingStepNext error: $e');
    }
  }

  /// Log when user taps "Start App" on the final onboarding screen.
  Future<void> logOnboardingCompleted() async {
    try {
      await _analytics.logEvent(
        name: 'onboarding_completed',
      );
      await _analytics.logTutorialComplete();
      debugPrint('[Analytics] Logged onboarding_completed');
    } catch (e) {
      debugPrint('[Analytics] logOnboardingCompleted error: $e');
    }
  }
}
