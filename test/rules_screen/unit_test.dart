// RULES SCREEN – UNIT TESTS
// Note: RulesScreen is a StatelessWidget; it is used inside the _RuleLabSheet
// in home_screen.dart (not as a standalone route). Tests use it directly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/rules_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  int _capturedBirth = 3;
  int _capturedSMin = 2;
  int _capturedSMax = 3;

  Widget buildRulesScreen({int b = 3, int sMin = 2, int sMax = 3}) {
    return wrapWithMaterial(
      Material(
        child: RulesScreen(
          birthRule: b,
          surviveMin: sMin,
          surviveMax: sMax,
          onBirthChanged: (v) => _capturedBirth = v,
          onSurviveMinChanged: (v) => _capturedSMin = v,
          onSurviveMaxChanged: (v) => _capturedSMax = v,
        ),
      ),
    );
  }

  group('[Unit] RulesScreen – Content rendering', () {
    testWidgets('renders RULES LAB heading', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen());
      await tester.pump();
      expect(find.text('RULES LAB'), findsOneWidget);
    });

    testWidgets('renders Birth Rule slider card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen());
      await tester.pump();
      await tester.dragUntilVisible(find.text('BIRTH RULE'), find.byType(ListView), const Offset(0, -200));
      expect(find.text('BIRTH RULE'), findsOneWidget);
    });

    testWidgets('renders Survive Min slider card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen());
      await tester.pump();
      await tester.dragUntilVisible(find.text('SURVIVE (MIN)'), find.byType(ListView), const Offset(0, -200));
      expect(find.text('SURVIVE (MIN)'), findsOneWidget);
    });

    testWidgets('renders Survive Max slider card', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen());
      await tester.pump();
      await tester.dragUntilVisible(find.text('SURVIVE (MAX)'), find.byType(ListView), const Offset(0, -200));
      expect(find.text('SURVIVE (MAX)'), findsOneWidget);
    });

    testWidgets('renders Reset button', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen());
      await tester.pump();
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('displays current birthRule value as text', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen(b: 5));
      await tester.pump();
      // The slider card shows the current value as a Text widget
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('displays current surviveMin value as text', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildRulesScreen(sMin: 1));
      await tester.pump();
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('Reset button triggers callbacks with standard values', (tester) async {
      setTestViewport(tester);
      int b = 5, sMin = 5, sMax = 5;
      await tester.pumpWidget(wrapWithMaterial(
        Material(
          child: RulesScreen(
            birthRule: b, surviveMin: sMin, surviveMax: sMax,
            onBirthChanged: (v) => b = v,
            onSurviveMinChanged: (v) => sMin = v,
            onSurviveMaxChanged: (v) => sMax = v,
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pump();

      expect(b, 3);
      expect(sMin, 2);
      expect(sMax, 3);
    });
  });
}
