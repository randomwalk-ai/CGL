// LEARN SCREEN – INTEGRATION TESTS
// Tests FAQ expansion logic and _MiniDemo lifecycle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/learn_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  Future<void> _dispose(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pump(const Duration(milliseconds: 700));
  }

  group('[Integration] LearnScreen – FAQ interaction', () {
    testWidgets('tapping FAQ question expands and shows answer', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.dragUntilVisible(
        find.text('Is this a game you play?'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );

      // Before expanding – answer should not be visible
      expect(find.textContaining('zero-player game'), findsNothing);

      await tester.tap(find.text('Is this a game you play?'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('zero-player game'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('expanding one FAQ does not reveal another FAQ answer', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.dragUntilVisible(
        find.text('Is this a game you play?'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );

      await tester.tap(find.text('Is this a game you play?'));
      await tester.pump(const Duration(milliseconds: 400));

      // Second FAQ answer ("John Conway in 1970") should still be hidden
      expect(find.textContaining('John Conway in 1970'), findsNothing);
      await _dispose(tester);
    });

    testWidgets('_MiniDemo timer cancels on dispose – no pending timer', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Unmount
      await _dispose(tester);
      // No pending timer exception = pass
    });
  });
}
