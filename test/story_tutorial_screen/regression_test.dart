// STORY TUTORIAL SCREEN – REGRESSION TESTS
// Ensures animation controllers are disposed.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/story_tutorial_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1500));
}

void main() {
  group('[Regression] StoryTutorialScreen – Resource cleanup', () {
    testWidgets('dispose cancels _swipeController and future delays',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      await _dispose(tester);
      // Reached here = no crash or leak exception
    });
  });
}
