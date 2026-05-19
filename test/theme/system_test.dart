// THEME – SYSTEM TESTS
// Verifies theme colours render correctly inside actual widgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/theme.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[System] Theme – Visual consistency in widgets', () {
    testWidgets('Text with color=green renders in the correct colour', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(
        wrapWithMaterial(
          const Text('LIFE LAB', style: TextStyle(color: green)),
        ),
      );
      await tester.pump();

      final textWidget = tester.widget<Text>(find.text('LIFE LAB'));
      expect(textWidget.style?.color, green);
    });

    testWidgets('Container with bg color renders without error', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(
        wrapWithMaterial(
          Container(color: bg, child: const SizedBox(width: 100, height: 100)),
        ),
      );
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, bg);
    });

    testWidgets('useMaterial3 is enabled in the theme', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const Scaffold()));
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}
