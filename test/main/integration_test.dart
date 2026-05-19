// MAIN APP – INTEGRATION TESTS
// Verifies theme propagation from the root.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/main.dart';
import 'package:life_lab/theme.dart';

void main() {
  group('[Integration] Main – Theme Propagation', () {
    testWidgets('MaterialApp applies dark theme and custom colors from main.dart', (tester) async {
      await tester.pumpWidget(const LifeLab());
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      expect(app.theme?.scaffoldBackgroundColor.value, bg.value);
      expect(app.theme?.brightness, Brightness.dark);
      expect(app.theme?.sliderTheme.activeTrackColor?.value, green.value);
      expect(app.theme?.useMaterial3, isTrue);
    });

    testWidgets('WelcomeScreen child inherits theme from LifeLab', (tester) async {
      await tester.pumpWidget(const LifeLab());
      // pump() instead of pumpAndSettle() because of repeating glow animation
      await tester.pump(const Duration(seconds: 1));

      // Find a widget that uses the theme, e.g., the background scaffold
      final BuildContext context = tester.element(find.byType(Scaffold).first);
      final theme = Theme.of(context);
      expect(theme.scaffoldBackgroundColor.value, bg.value);
    });
  });
}
