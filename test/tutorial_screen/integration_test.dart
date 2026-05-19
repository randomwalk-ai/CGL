// TUTORIAL SCREEN – INTEGRATION TESTS
// Tests page switching, skipping, and final slide buttons.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/tutorial_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  group('[Integration] TutorialScreen – Navigation', () {
    testWidgets('tapping NEXT moves to Rules of Life slide', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Use drag for more deterministic page switching when infinite timers are present
      await tester.drag(find.byType(PageView), const Offset(-600, 0));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('Rules of Life'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('tapping SKIP jumps to Interactive Demo slide', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('SKIP'));
      await tester.pump(const Duration(milliseconds: 1000));

      // The last slide is Interactive Demo
      expect(find.text('Interactive Demo'), findsOneWidget);
      await _dispose(tester);
    });
  });

  group('[Integration] TutorialScreen – Interactive Demo', () {
    testWidgets('Play Demo button appears and can be tapped', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('SKIP'));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('Play Demo'), findsOneWidget);
      
      await tester.tap(find.text('Play Demo'));
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.textContaining('Simulation is running'), findsOneWidget);
      await _dispose(tester);
    });
  });
}
