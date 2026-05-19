// LEARN SCREEN – REGRESSION TESTS
// Protects against timer leaks from _MiniDemo and content rendering regressions.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/learn_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Regression] LearnScreen – Timer cleanup', () {
    testWidgets('mounting and immediately unmounting does not leak timers',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      // Immediately unmount
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(milliseconds: 700));
      // No timer exception = passed
    });
  });

  group('[Regression] LearnScreen – Content regressions', () {
    testWidgets('4 rule cards are always rendered in THE RULES section',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      for (final label in ['SURVIVAL', 'BIRTH', 'DEATH (Lonely)', 'DEATH (Crowded)']) {
        await tester.dragUntilVisible(find.text(label), find.byType(ListView).first, const Offset(0, -200));
        expect(find.text(label), findsOneWidget, reason: 'Missing rule: $label');
      }
    });

    testWidgets('4 FAQ questions are always present', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      const questions = [
        'Is this a game you play?',
        "Why is it called the 'Game of Life'?",
        'What are Gliders?',
        'Can I change the rules?',
      ];
      for (final q in questions) {
        await tester.dragUntilVisible(find.text(q), find.byType(ListView).first, const Offset(0, -300));
        expect(find.text(q), findsOneWidget, reason: 'Missing FAQ: $q');
      }
    });
  });
}
