// RULES SCREEN – REGRESSION TESTS
// Ensures Reset always returns exactly (3, 2, 3) and slider range never changes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Regression] RulesScreen – Standard values protection', () {
    testWidgets('Reset always sets birth=3, surviveMin=2, surviveMax=3',
        (tester) async {
      setTestViewport(tester);
      int b = 0, sMin = 0, sMax = 0;

      await tester.pumpWidget(
        wrapWithMaterial(
          Material(
            child: RulesScreen(
              birthRule: 7,
              surviveMin: 1,
              surviveMax: 8,
              onBirthChanged: (v) => b = v,
              onSurviveMinChanged: (v) => sMin = v,
              onSurviveMaxChanged: (v) => sMax = v,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(b, 3, reason: 'Birth rule should reset to 3');
      expect(sMin, 2, reason: 'Survive min should reset to 2');
      expect(sMax, 3, reason: 'Survive max should reset to 3');
    });

    testWidgets('Slider min/max never changes from (1, 8)', (tester) async {
      setTestViewport(tester);
      // Test with non-standard initial values
      await tester.pumpWidget(
        wrapWithMaterial(
          Material(
            child: RulesScreen(
              birthRule: 1,
              surviveMin: 1,
              surviveMax: 8,
              onBirthChanged: (_) {},
              onSurviveMinChanged: (_) {},
              onSurviveMaxChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      for (final s in tester.widgetList<Slider>(find.byType(Slider))) {
        expect(s.min, 1.0, reason: 'Slider min must be 1.0');
        expect(s.max, 8.0, reason: 'Slider max must be 8.0');
      }
    });
  });
}
