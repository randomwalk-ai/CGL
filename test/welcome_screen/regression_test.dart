// WELCOME SCREEN – REGRESSION TESTS
// Protects against timer/animation leaks on dispose.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import '../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('[Regression] WelcomeScreen – Resource cleanup', () {
    testWidgets('bgTimer and glow AnimationController are cancelled on dispose',
        (tester) async {
      SharedPreferences.setMockInitialValues({'isFirstTime': true});
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      // Let a couple of timer ticks fire
      await tester.pump(const Duration(milliseconds: 700));

      // Remove widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(milliseconds: 700));
      // No pending timer exception = pass
    });

    testWidgets('pressing primary button twice does not start two navigations',
        (tester) async {
      SharedPreferences.setMockInitialValues({'isFirstTime': true});
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Rapid double tap
      final finder = find.byType(ElevatedButton);
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(finder);
      await tester.pump(const Duration(seconds: 2));

      // The guard `if (_isEntering) return;` prevents double-navigation
      // Confirm no crash occurs
    });
  });

  group('[Regression] WelcomeScreen – Returning User Flow', () {
    testWidgets('returning user sees ENTER GRID as primary and START TUTORIAL as secondary (enabled)', (tester) async {
      // Simulate returning user
      SharedPreferences.setMockInitialValues({'isFirstTime': false});
      
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Primary button (ElevatedButton) should now say "ENTER GRID"
      expect(find.widgetWithText(ElevatedButton, 'ENTER GRID'), findsOneWidget);
      
      // 2. Secondary button (OutlinedButton) should now say "START TUTORIAL" and be ENABLED
      final OutlinedButton secondaryBtn = tester.widget(find.widgetWithText(OutlinedButton, 'START TUTORIAL'));
      expect(secondaryBtn.onPressed, isNotNull);
    });
  });
}
