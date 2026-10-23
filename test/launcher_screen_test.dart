import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_skins_tool/main.dart';
import 'package:rbx_skins_tool/screens/home_screen.dart';
import 'package:rbx_skins_tool/screens/launcher/launcher_home_screen.dart';
import 'package:rbx_skins_tool/screens/launcher/widgets/google_search_bar_widget.dart';
import 'package:rbx_skins_tool/screens/launcher/widgets/launcher_clock_widget.dart';
import 'package:rbx_skins_tool/screens/launcher/widgets/launcher_dock_widget.dart';
import 'package:rbx_skins_tool/screens/onboarding/question_screen.dart';
import 'package:rbx_skins_tool/services/default_app_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DefaultAppService.debugMockIsDefault = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.clothe.skin.roblox.emotes.shirt.rbxconverter.calculator.ai/default_launcher'),
      (MethodCall call) async {
        if (call.method == 'isDefaultLauncher') return true;
        if (call.method == 'getInstalledApps') return [];
        return true;
      },
    );
  });

  tearDown(() {
    DefaultAppService.debugMockIsDefault = null;
  });

  group('Launcher Components Tests', () {
    testWidgets('LauncherClockWidget renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LauncherClockWidget(),
          ),
        ),
      );

      // Verify clock time and AM/PM are rendered
      expect(find.byType(LauncherClockWidget), findsOneWidget);
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('GoogleSearchBarWidget renders Google logo and search hint',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoogleSearchBarWidget(),
          ),
        ),
      );

      expect(find.byType(GoogleSearchBarWidget), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('LauncherDockWidget renders Phone, Contacts, Messages',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LauncherDockWidget(),
          ),
        ),
      );

      expect(find.byType(LauncherDockWidget), findsOneWidget);
      expect(find.byIcon(Icons.phone_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    });

    testWidgets('LauncherHomeScreen builds and displays primary launcher views',
        (tester) async {
      await appState.completeOnboarding();

      await tester.pumpWidget(
        const MaterialApp(
          home: LauncherHomeScreen(),
        ),
      );

      await tester.pump();

      expect(find.byType(LauncherHomeScreen), findsOneWidget);
      expect(find.byType(LauncherClockWidget), findsOneWidget);
      expect(find.byType(GoogleSearchBarWidget), findsOneWidget);
      expect(find.byType(LauncherDockWidget), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('LauncherHomeScreen displays OnboardingFlow when onboarding incomplete',
        (tester) async {
      await appState.resetOnboarding();

      await tester.pumpWidget(
        const MaterialApp(
          home: LauncherHomeScreen(initialPage: 1),
        ),
      );

      await tester.pump();

      expect(find.byType(OnboardingFlow), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('LauncherHomeScreen displays HomeScreen on page 0 when onboarding complete',
        (tester) async {
      await appState.completeOnboarding();

      await tester.pumpWidget(
        const MaterialApp(
          home: LauncherHomeScreen(initialPage: 0),
        ),
      );

      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('LauncherHomeScreen redirects to HomeScreen when app is not default launcher',
        (tester) async {
      await appState.completeOnboarding();
      DefaultAppService.debugMockIsDefault = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: LauncherHomeScreen(initialPage: 1),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

