// WELCOME SCREEN – INTEGRATION TESTS
// Tests button press behaviour and navigation (using fake navigator).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Integration] WelcomeScreen – Button behaviour', () {
    testWidgets('tapping START TUTORIAL does not throw immediately', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap the primary button
      await tester.tap(find.text('START TUTORIAL'));
      await tester.pump(const Duration(seconds: 2));

      // _isEntering should now be true – the bg grid scale animation begins.
      // We can't access private state, but we confirm no exception was thrown.
    });

    testWidgets('secondary button ENTER GRID is null (disabled) on first visit',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton).first);
      expect(btn.onPressed, isNull);
    });

    testWidgets('background grid GridView is rendered', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // The background GridView is rendered (IgnorePointer wraps it)
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
