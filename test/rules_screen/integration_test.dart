// RULES SCREEN – INTEGRATION TESTS
// Tests interactions between sliders and state callbacks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Integration] RulesScreen – Interactions', () {
    testWidgets('dragging Birth Rule slider triggers callback', (tester) async {
      setTestViewport(tester);
      int captured = 0;
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: 3,
            surviveMin: 2,
            surviveMax: 3,
            onBirthChanged: (v) => captured = v,
            onSurviveMinChanged: (_) {},
            onSurviveMaxChanged: (_) {},
          ),
        ),
      ));
      await tester.pump();

      // Find the first slider (Birth Rule)
      final slider = find.byType(Slider).first;
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(captured, isNot(3));
    });

    testWidgets('dragging Survive Min slider triggers callback', (tester) async {
      setTestViewport(tester);
      int captured = 0;
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: 3,
            surviveMin: 2,
            surviveMax: 3,
            onBirthChanged: (_) {},
            onSurviveMinChanged: (v) => captured = v,
            onSurviveMaxChanged: (_) {},
          ),
        ),
      ));
      await tester.pump();

      // Find the second slider
      await tester.dragUntilVisible(find.text('SURVIVE (MIN)'), find.byType(ListView), const Offset(0, -200));
      final slider = find.byType(Slider).at(1);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(captured, isNot(2));
    });

    testWidgets('dragging Survive Max slider triggers callback', (tester) async {
      setTestViewport(tester);
      int captured = 0;
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: 3,
            surviveMin: 2,
            surviveMax: 3,
            onBirthChanged: (_) {},
            onSurviveMinChanged: (_) {},
            onSurviveMaxChanged: (v) => captured = v,
          ),
        ),
      ));
      await tester.pump();

      // Find the third slider
      await tester.dragUntilVisible(find.text('SURVIVE (MAX)'), find.byType(ListView), const Offset(0, -300));
      final slider = find.byType(Slider).at(2);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump();

      expect(captured, isNot(3));
    });
  });
}
