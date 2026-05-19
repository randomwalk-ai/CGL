// PLAY SCREEN – SYSTEM TESTS
// End-to-end simulation: stabilization, extinction, oscillation, generation.
// Each test properly cancels the timer and disposes the widget to prevent
// 'timersPending' assertion failures from _pulseController and Timer.periodic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:life_lab/play_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester, GlobalKey<PlayScreenState> key) async {
  key.currentState?.pause();
  await tester.pumpWidget(const SizedBox());
  // Allow the 4-second Future.delayed in _triggerOverlay to finish
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  final GlobalKey<PlayScreenState> testPlayKey = GlobalKey<PlayScreenState>();

  group('[System] PlayScreen – Stabilization detection', () {
    testWidgets('2x2 still life triggers isWin=true after first tick', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        final g = testPlayKey.currentState!.grid;
        g[10][10] = 1; g[10][11] = 1;
        g[11][10] = 1; g[11][11] = 1;
        testPlayKey.currentState!.history = [gridToString(g)];
      });
      testPlayKey.currentState!.start();
      // Default 500ms/tick; pump 600ms for exactly one tick
      await tester.pump(const Duration(milliseconds: 600));

      expect(testPlayKey.currentState!.isWin, isTrue);
      expect(testPlayKey.currentState!.gameEndTitle, contains('survived'));
      // Timer must auto-cancel on stable state
      expect(testPlayKey.currentState!.timer?.isActive, isNot(true));
      await _dispose(tester, testPlayKey);
    });
  });

  group('[System] PlayScreen – Extinction detection', () {
    testWidgets('two isolated cells both die – triggers isWin=false', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        final g = testPlayKey.currentState!.grid;
        g[10][10] = 1;
        g[10][14] = 1; // separated by >1 cell – each has 0 neighbors
        testPlayKey.currentState!.history = [gridToString(g)];
      });
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 600));

      expect(testPlayKey.currentState!.isWin, isFalse);
      expect(testPlayKey.currentState!.gameEndTitle, contains('failed'));
      expect(testPlayKey.currentState!.timer?.isActive, isNot(true));
      await _dispose(tester, testPlayKey);
    });
  });

  group('[System] PlayScreen – Oscillation detection', () {
    testWidgets('vertical blinker oscillation detected → isWin=true, title contains looping',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Vertical blinker: period 2 ticks
      testPlayKey.currentState!.setState(() {
        final g = testPlayKey.currentState!.grid;
        g[9][10]  = 1;
        g[10][10] = 1;
        g[11][10] = 1;
        testPlayKey.currentState!.history = [gridToString(g)];
      });
      testPlayKey.currentState!.start();
      // 2 ticks at 500ms each = 1200ms
      await tester.pump(const Duration(milliseconds: 1200));

      expect(testPlayKey.currentState!.isWin, isTrue);
      expect(testPlayKey.currentState!.gameEndTitle, contains('looping'));
      await _dispose(tester, testPlayKey);
    });
  });

  group('[System] PlayScreen – Generation counter', () {
    testWidgets('generation increments from 0 to 1 after first tick', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Place a 2x2 block (wins after tick 1 but gen is incremented first)
      testPlayKey.currentState!.setState(() {
        final g = testPlayKey.currentState!.grid;
        g[10][10] = 1; g[10][11] = 1;
        g[11][10] = 1; g[11][11] = 1;
        testPlayKey.currentState!.history = [gridToString(g)];
      });
      expect(testPlayKey.currentState!.generation, 0);
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 600));

      expect(testPlayKey.currentState!.generation, greaterThanOrEqualTo(1));
      await _dispose(tester, testPlayKey);
    });
  });

  group('[System] PlayScreen – Pause behaviour', () {
    testWidgets('pause() stops generation from incrementing further', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Vertical blinker – won't end immediately (oscillates)
      testPlayKey.currentState!.setState(() {
        final g = testPlayKey.currentState!.grid;
        g[9][10]  = 1;
        g[10][10] = 1;
        g[11][10] = 1;
        testPlayKey.currentState!.history = [gridToString(g)];
      });
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 600));
      final genAtPause = testPlayKey.currentState!.generation;

      testPlayKey.currentState!.pause();
      // Advance time – generation must not change after pause
      await tester.pump(const Duration(milliseconds: 600));
      expect(testPlayKey.currentState!.generation, genAtPause);
      await _dispose(tester, testPlayKey);
    });
  });

  group('[System] PlayScreen – tryAgain resets state', () {
    testWidgets('tryAgain() resets all state to fresh', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.gameEndTitle = 'survived';
        testPlayKey.currentState!.isWin = true;
        testPlayKey.currentState!.generation = 10;
      });
      await tester.pump();

      testPlayKey.currentState!.tryAgain();
      await tester.pump();

      expect(testPlayKey.currentState!.gameEndTitle, isNull);
      expect(testPlayKey.currentState!.isWin, isFalse);
      expect(testPlayKey.currentState!.generation, 0);
      await _dispose(tester, testPlayKey);
    });
  });
}
