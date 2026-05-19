// STORY TUTORIAL SCREEN – INTEGRATION TESTS
// Tests step advancement and navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/story_tutorial_screen.dart';
import '../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'isFirstTime': true});
  });

  group('[Integration] StoryTutorialScreen - Interaction', () {
    testWidgets('tapping the target cell in step 1 advances state', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // The cells are AnimatedContainers inside GestureDetector. 
      // Cell 45 is in the center of the 10x10 grid.
      final cell45 = find.byType(AnimatedContainer).at(45);
      await tester.tap(cell45);
      await tester.pump(const Duration(milliseconds: 500));

      // After tapping, it triggers animations (Wait for _playNeighborsAnimation)
      await tester.pump(const Duration(seconds: 5));
      
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('tapping SKIP triggers navigation', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('SKIP'));
      // Wait for SharedPreferences and Navigation
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(StoryTutorialScreen), findsNothing);
    });
  });
}
