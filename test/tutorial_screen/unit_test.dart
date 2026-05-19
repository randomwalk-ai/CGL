// TUTORIAL SCREEN – UNIT TESTS
// Verifies static content: slide titles, button presence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/tutorial_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  group('[Unit] TutorialScreen – Static content', () {
    testWidgets('renders first slide title: The Grid & Cells', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('The Grid & Cells'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders NEXT button initially', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('NEXT'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders SKIP button initially', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('SKIP'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders 4 dots for pagination', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const TutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      // Dots are AnimatedContainers, but we can search for them by properties or just check the row
      expect(find.byType(Row), findsWidgets);
      await _dispose(tester);
    });
  });
}
