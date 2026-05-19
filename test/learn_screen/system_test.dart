// LEARN SCREEN – SYSTEM TESTS
// Verifies LearnScreen renders correctly within the full HomeScreen navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[System] LearnScreen – Inside HomeScreen navigation', () {
    testWidgets('switching to Learn tab shows LearnScreen content', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen());
      await tester.pump(const Duration(milliseconds: 500));

      // Switch to Learn tab
      await tester.tap(find.byIcon(Icons.school));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('ABOUT THE GAME'), findsOneWidget);
    });

    testWidgets('LearnScreen content is scrollable', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildHomeScreen(initialTab: 1));
      await tester.pump(const Duration(milliseconds: 500));

      // Scroll down to bring the FAQ section into view
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 300));

      // After scrolling, FAQ heading should be in view
      await tester.dragUntilVisible(find.text('FAQ'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('FAQ'), findsOneWidget);
    });
  });
}
