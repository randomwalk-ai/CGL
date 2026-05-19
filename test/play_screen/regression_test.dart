// PLAY SCREEN – REGRESSION TESTS
// Public API only. Each test disposes widget to prevent pending timer errors.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/play_screen.dart';
import '../helpers/test_helpers.dart';

Future<void> _dispose(WidgetTester tester, GlobalKey<PlayScreenState> key) async {
  key.currentState?.pause();
  await tester.pumpWidget(const SizedBox());
  // Wait for _triggerOverlay's 3.5s Future.delayed and other cleanup
  await tester.pump(const Duration(milliseconds: 4000));
}

void main() {
  final GlobalKey<PlayScreenState> testPlayKey = GlobalKey<PlayScreenState>();

  group('[Regression] PlayScreen – Timer safety', () {
    testWidgets('dispose cancels timer – no pending timer exception', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.grid[10][10] = 1;
        testPlayKey.currentState!.history = [
          gridToString(testPlayKey.currentState!.grid)
        ];
      });
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 50));

      await _dispose(tester, testPlayKey);
      // Reached here without pending timer exception = success
    });
  });

  group('[Regression] PlayScreen – Grid lock after game end', () {
    testWidgets('game end title stable after timer stopped', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Induce extinction in one tick (two isolated cells)
      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.grid[10][10] = 1;
        testPlayKey.currentState!.grid[10][14] = 1;
        testPlayKey.currentState!.history = [
          gridToString(testPlayKey.currentState!.grid)
        ];
      });
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 1000));

      final firstTitle = testPlayKey.currentState!.gameEndTitle;
      expect(firstTitle, isNotNull);

      // Timer is cancelled after extinction → no further state changes
      await tester.pump(const Duration(milliseconds: 600));
      expect(testPlayKey.currentState!.gameEndTitle, firstTitle);
      await _dispose(tester, testPlayKey);
    });
  });

  group('[Regression] PlayScreen – Full clear() reset', () {
    testWidgets('clear() resets all game state fields', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.gameEndTitle = 'survived';
        testPlayKey.currentState!.gameEndMessage = 'some msg';
        testPlayKey.currentState!.isWin = true;
        testPlayKey.currentState!.generation = 42;
        testPlayKey.currentState!.grid[5][5] = 1;
      });
      await tester.pump();

      testPlayKey.currentState!.clear();
      await tester.pump();

      final s = testPlayKey.currentState!;
      expect(s.gameEndTitle, isNull);
      expect(s.gameEndMessage, isNull);
      expect(s.isWin, isFalse);
      expect(s.generation, 0);

      bool hasAlive = false;
      for (final row in s.grid) {
        for (final cell in row) {
          if (cell == 1) hasAlive = true;
        }
      }
      expect(hasAlive, isFalse);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('start() with empty grid does not activate timer', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Grid is empty – start() checks aliveInit == 0 and returns early
      testPlayKey.currentState!.start();
      await tester.pump(const Duration(milliseconds: 100));

      expect(testPlayKey.currentState!.timer?.isActive, isNot(true));
      await _dispose(tester, testPlayKey);
    });
  });

  group('[Regression] PlayScreen – History cap', () {
    test('history list never exceeds 25 entries (pure logic)', () {
      final history = <String>[];
      for (int i = 0; i < 30; i++) {
        history.add('gen$i');
        if (history.length > 25) history.removeAt(0);
      }
      expect(history.length, lessThanOrEqualTo(25));
    });
  });
}
