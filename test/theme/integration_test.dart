// THEME – INTEGRATION TESTS
// Verifies the MaterialApp ThemeData built in main.dart applies theme constants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/theme.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Integration] Theme – Applied in MaterialApp', () {
    testWidgets('scaffoldBackgroundColor equals bg constant', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const Scaffold()));
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.scaffoldBackgroundColor, bg);
    });

    testWidgets('app uses dark brightness', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const Scaffold()));
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.dark);
    });

    testWidgets('slider activeTrackColor equals green constant', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const Scaffold()));
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.sliderTheme.activeTrackColor, green);
    });

    testWidgets('slider thumbColor equals green constant', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const Scaffold()));
      await tester.pump();

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.sliderTheme.thumbColor, green);
    });
  });
}
