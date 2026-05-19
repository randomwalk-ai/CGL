// LEARN SCREEN – UNIT TESTS
// Verifies content presence: section headings, rule names, FAQ questions.
// Each test disposes by replacing widget tree to cancel _MiniDemo timers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/learn_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  group('[Unit] LearnScreen – Content rendering', () {
    testWidgets('renders ABOUT THE GAME heading', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ABOUT THE GAME'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders THE RULES heading after scroll', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('THE RULES'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('THE RULES'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders FAQ heading after scroll', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('FAQ'), find.byType(ListView).first, const Offset(0, -300));
      expect(find.text('FAQ'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders SURVIVAL rule card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('SURVIVAL'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('SURVIVAL'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders BIRTH rule card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('BIRTH'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('BIRTH'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders DEATH (Lonely) rule card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('DEATH (Lonely)'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('DEATH (Lonely)'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders DEATH (Crowded) rule card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(find.text('DEATH (Crowded)'), find.byType(ListView).first, const Offset(0, -200));
      expect(find.text('DEATH (Crowded)'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders first FAQ question text', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.dragUntilVisible(
        find.text('Is this a game you play?'),
        find.byType(ListView).first,
        const Offset(0, -400),
      );
      expect(find.text('Is this a game you play?'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders Randomwalk.ai hyperlink text', (tester) async {
      setTestViewport(tester, width: 1200);
      await tester.pumpWidget(wrapWithMaterial(const LearnScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      
      // Scroll to the bottom manually
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pumpAndSettle(const Duration(milliseconds: 100)); // Should be fast enough if no timers
      
      // Use find.byWidgetPredicate to find the RichText containing the string
      final richTextFinder = find.byWidgetPredicate((widget) => 
        widget is RichText && widget.text.toPlainText().contains('Randomwalk.ai'));
      
      expect(richTextFinder, findsOneWidget);
      await _dispose(tester);
    });
  });
}
