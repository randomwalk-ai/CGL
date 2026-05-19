// MAIN APP – UNIT TESTS
// Verifies root widget configuration.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/main.dart';
import 'package:life_lab/welcome_screen.dart';

void main() {
  group('[Unit] Main – LifeLab Root Widget', () {
    testWidgets('LifeLab renders a MaterialApp', (tester) async {
      await tester.pumpWidget(const LifeLab());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('LifeLab starts with WelcomeScreen as home', (tester) async {
      await tester.pumpWidget(const LifeLab());
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('MaterialApp has debug flag disabled', (tester) async {
      await tester.pumpWidget(const LifeLab());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });
}
