// HOME SCREEN – SYSTEM TESTS
// Full navigation flows: welcome → home, Rule Lab sheet open/close.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/home_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[System] HomeScreen – Entry navigation', () {
    testWidgets('HomeScreen renders without crashing inside MaterialApp',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));
      // Confirm core UI is alive
      expect(find.text('LIFE LAB'), findsOneWidget);
    });

    testWidgets('HomeScreen shows scaffold with body and bottomNavigationBar',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Scaffold), findsWidgets);
      // Nav bar items
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });
  });

  group('[System] HomeScreen – Rule Lab bottom sheet', () {
    testWidgets('opening Rule Lab sheet displays RULE LAB title', (tester) async {
      // Use a tall viewport to ensure bottom sheet content is reachable
      setTestViewport(tester, height: 2000);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Verify sheet is not initially visible
      expect(find.text('RULE LAB'), findsNothing);

      // 2. Find the rule lab button (tune icon) and tap it
      final ruleLabBtn = find.byIcon(Icons.tune);
      expect(ruleLabBtn, findsOneWidget);
      
      await tester.tap(ruleLabBtn);
      // Pump for bottom sheet animation
      await tester.pump(const Duration(milliseconds: 1000));

      // 3. Verify sheet content
      expect(find.text('RULE LAB'), findsOneWidget);
      
      // Tap the button using a more precise finder and ensure it's hit
      final saveBtn = find.widgetWithText(ElevatedButton, 'SAVE AND PLAY');
      await tester.ensureVisible(saveBtn);
      await tester.pump(const Duration(milliseconds: 200));
      
      // Tap using a coordinate hit test bypass if needed, but tap should work after ensureVisible
      await tester.tap(saveBtn);
      
      // Pump for bottom sheet closing animation
      // We use a large duration and pump multiple frames to ensure it's gone
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.text('RULE LAB'), findsNothing);
    });
  });
}
