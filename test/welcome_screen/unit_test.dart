// WELCOME SCREEN – UNIT TESTS
// Tests static content, button labels, and animation controller safety.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Unit] WelcomeScreen – Static content', () {
    testWidgets('renders WELCOME TO text', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('WELCOME TO'), findsOneWidget);
    });

    testWidgets("renders CONWAY'S GAME OF LIFE title", (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining("GAME OF LIFE"), findsOneWidget);
    });

    testWidgets('renders Touch • Create • Evolve tagline', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Touch • Create • Evolve'), findsOneWidget);
    });

    testWidgets('renders auto_awesome icon', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('first-time: primary button shows START TUTORIAL', (tester) async {
      // Default SharedPreferences has isFirstTime=true (not set = defaults to true)
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('START TUTORIAL'), findsOneWidget);
    });

    testWidgets('first-time: secondary button shows ENTER GRID (disabled)', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      // Secondary button text is ENTER GRID when _isFirstTime=true
      expect(find.text('ENTER GRID'), findsOneWidget);
      // The secondary OutlinedButton is disabled (null onPressed) for first-time
      final outlinedBtns = tester.widgetList<OutlinedButton>(find.byType(OutlinedButton)).toList();
      expect(outlinedBtns.first.onPressed, isNull);
    });
  });
}
