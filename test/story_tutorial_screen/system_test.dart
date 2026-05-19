// STORY TUTORIAL SCREEN – SYSTEM TESTS
// Verifies full flow through the story steps.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/story_tutorial_screen.dart';
import '../helpers/test_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'isFirstTime': true});
  });

  group('[System] StoryTutorialScreen - Flow', () {
    testWidgets('can reach step 2: Rule 1: Isolation', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const StoryTutorialScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Step 1 -> Step 2
      // Cells are now in a ListView, but let's just find them by index
      final cell45 = find.byType(AnimatedContainer).at(45);
      await tester.tap(cell45);
      await tester.pump(const Duration(seconds: 6)); // Wait for animation
      
      // NEXT button might be off-screen in the ListView
      await tester.dragUntilVisible(
        find.text('NEXT'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      
      await tester.tap(find.text('NEXT'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Rule 1: Isolation'), findsOneWidget);
    });
  });
}
