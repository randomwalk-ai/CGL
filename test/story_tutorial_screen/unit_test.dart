// STORY TUTORIAL SCREEN – UNIT TESTS
// Verifies initial state and text.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/story_tutorial_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  group('[Unit] StoryTutorialScreen – Initial state', () {
    testWidgets('renders initial title: The Grid', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('The Grid'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders initial subtitle', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('Tap the glowing center cell to begin'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('renders SKIP button', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('SKIP'), findsOneWidget);
      await _dispose(tester);
    });

    testWidgets('BACK button is not present on first step', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      
      expect(find.text('BACK'), findsNothing);
      await _dispose(tester);
    });
  });
}
