// RULES SCREEN – SYSTEM TESTS
// Verifies layout consistency and scrollability.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[System] RulesScreen – Full rendering', () {
    testWidgets('renders all content without overflow on standard viewport',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: 3,
            surviveMin: 2,
            surviveMax: 3,
            onBirthChanged: (_) {},
            onSurviveMinChanged: (_) {},
            onSurviveMaxChanged: (_) {},
          ),
        ),
      ));
      await tester.pump();

      // Ensure we can scroll to the bottom
      await tester.dragUntilVisible(
        find.text('SURVIVE (MAX)'),
        find.byType(ListView),
        const Offset(0, -500),
      );

      expect(find.text('SURVIVE (MAX)'), findsOneWidget);
    });

    testWidgets('renders correctly on small viewport (scroll check)',
        (tester) async {
      // Small phone viewport
      setTestViewport(tester, width: 320, height: 480);
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: 3,
            surviveMin: 2,
            surviveMax: 3,
            onBirthChanged: (_) {},
            onSurviveMinChanged: (_) {},
            onSurviveMaxChanged: (_) {},
          ),
        ),
      ));
      await tester.pump();

      // Start of screen
      expect(find.text('RULES LAB'), findsOneWidget);

      // Scroll to middle
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();

      // Scroll to end
      await tester.dragUntilVisible(
        find.text('SURVIVE (MAX)'),
        find.byType(ListView),
        const Offset(0, -200),
      );

      expect(find.text('SURVIVE (MAX)'), findsOneWidget);
    });
  });
}
