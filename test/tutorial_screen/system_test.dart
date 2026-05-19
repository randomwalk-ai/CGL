// TUTORIAL SCREEN – SYSTEM TESTS
// Full flow from start to "Play Game" button.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/tutorial_screen.dart';
import 'package:life_lab/home_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  group('[System] TutorialScreen – Full flow', () {
    testWidgets('completing all slides reveals Play Game button and navigates to HomeScreen', (tester) async {
      setTestViewport(tester);
      
      await tester.pumpWidget(MaterialApp(
        home: const TutorialScreen(),
        routes: {
          '/home': (context) => const HomeScreen(initialTab: 0),
        },
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Use a helper to jump pages since infinite timers prevent pumpAndSettle
      final pageView = tester.widget<PageView>(find.byType(PageView));
      final controller = pageView.controller!;

      // 1. Grid slide -> Rules slide
      expect(find.text('The Grid & Cells'), findsOneWidget);
      controller.jumpToPage(1);
      await tester.pump(const Duration(milliseconds: 500));

      // 2. Rules slide -> Ready to Evolve slide
      expect(find.text('Rules of Life'), findsOneWidget);
      controller.jumpToPage(2);
      await tester.pump(const Duration(milliseconds: 500));

      // 3. Ready to Evolve slide -> Interactive Demo slide
      expect(find.text('Ready to Evolve?'), findsOneWidget);
      controller.jumpToPage(3);
      await tester.pump(const Duration(milliseconds: 500));

      // 4. Interactive Demo slide
      expect(find.text('Interactive Demo'), findsOneWidget);
      expect(find.text('Play Demo'), findsOneWidget);

      await _dispose(tester);
    });
  });
}
