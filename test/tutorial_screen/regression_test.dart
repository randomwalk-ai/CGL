// TUTORIAL SCREEN – REGRESSION TESTS
// Ensures timers in _MiniDemo and _InteractiveDemoSlide are cleaned up.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/tutorial_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  group('[Regression] TutorialScreen – Timer cleanup', () {
    testWidgets('mounting and immediately unmounting does not leak timers',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      await _dispose(tester);
      // No exception means timers were disposed properly
    });

    testWidgets('Play Demo timer cancels on dispose', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('SKIP'));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Play Demo'));
      await tester.pump(const Duration(milliseconds: 100));

      await _dispose(tester);
      // No exception = success
    });
  });
}
