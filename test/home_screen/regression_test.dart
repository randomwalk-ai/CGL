// HOME SCREEN – REGRESSION TESTS

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Regression] HomeScreen – Navigation regressions', () {
    testWidgets('repeated tab switching does not crash', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      for (int i = 0; i < 4; i++) {
        await tester.tap(find.byIcon(Icons.school));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.byIcon(Icons.grid_view));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('LIFE LAB'), findsOneWidget);
    });

    testWidgets('HomeScreen disposes without pending timer exception',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 300));

      // Replace widget tree – triggers dispose on HomeScreen
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(milliseconds: 100));
      // No exception means timers and controllers were cleaned up
    });
  });
}
