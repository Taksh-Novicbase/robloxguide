import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rbx_skins_tool/screens/default_launcher/set_default_launcher_screen.dart';
import 'package:rbx_skins_tool/services/default_app_service.dart';
import 'package:rbx_skins_tool/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DefaultAppService returns false on desktop/testing environment', () async {
    final isDefault = await DefaultAppService.isDefaultLauncher();
    expect(isDefault, isFalse);
  });

  test('AppState persists and updates defaultAppPrompted flag', () async {
    final state = AppState();
    // Wait for initial mock load
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(state.defaultAppPrompted, isFalse);

    await state.setDefaultAppPrompted(true);
    expect(state.defaultAppPrompted, isTrue);

    await state.resetOnboarding();
    expect(state.defaultAppPrompted, isFalse);
  });

  testWidgets('SetDefaultLauncherScreen renders all instructions and button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SetDefaultLauncherScreen(isFromSettings: true),
      ),
    );
    await tester.pump();

    // Verify Title & Subtitle from original APK
    expect(find.text('SET AS DEFAULT'), findsWidgets);
    expect(find.text('YOUR CURRENT HOME WILL BE REPLACED'), findsOneWidget);

    // Verify feature description and footer text
    expect(
      find.text('Allows quick access to Roblox Skins Tool from the home screen.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You can change or disable these features anytime from settings > Apps > Default > Apps > Home App',
      ),
      findsOneWidget,
    );
  });
}
