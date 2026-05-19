// PLAY SCREEN – INTEGRATION TESTS
// Tests widget rendering, cell tapping, play/pause, generation counter.
// Only uses public API of PlayScreenState.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:life_lab/play_screen.dart';
import '../helpers/test_helpers.dart';

/// Unmounts the widget and pumps through all animations to prevent
/// pending timer errors from PlayScreen's _pulseController.
Future<void> _dispose(WidgetTester tester, GlobalKey<PlayScreenState> key) async {
  key.currentState?.pause();
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  final GlobalKey<PlayScreenState> testPlayKey = GlobalKey<PlayScreenState>();

  group('[Integration] PlayScreen – Rendering', () {
    testWidgets('renders LIFE LAB title', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('LIFE LAB'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('renders GEN 0 counter initially', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('GEN 0'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('shows Live cells drawn: 0 status on empty grid', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      // Status line when generation==0 and aliveCount==0
      expect(find.textContaining('Live cells drawn: 0'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('speed (bolt) button renders', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.bolt), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('help icon renders', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('tune (rule lab) icon renders', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.tune), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('high-score trophy icon renders', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.military_tech), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('Draw your starting cells hint text is shown initially',
        (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('Draw your starting cells'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });
  });

  group('[Integration] PlayScreen – Share button visibility', () {
    testWidgets('share button NOT visible before game ends', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byIcon(Icons.share), findsNothing);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('share button visible on WIN state', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.gameEndTitle =
            'Your pattern survived with 4 live cells';
        testPlayKey.currentState!.gameEndMessage = 'Stabilized after 2 gens.';
        testPlayKey.currentState!.isWin = true;
      });
      await tester.pump();
      expect(find.byIcon(Icons.share), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('share button NOT visible on LOSE state', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.gameEndTitle = 'Your pattern failed';
        testPlayKey.currentState!.gameEndMessage = 'All died.';
        testPlayKey.currentState!.isWin = false;
      });
      await tester.pump();
      expect(find.byIcon(Icons.share), findsNothing);
      await _dispose(tester, testPlayKey);
    });
  });

  group('[Integration] PlayScreen – Generation counter and grid state', () {
    testWidgets('clear() resets generation to 0 and shows GEN 0', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.generation = 7;
      });
      await tester.pump();
      expect(find.text('GEN 7'), findsOneWidget);

      testPlayKey.currentState!.clear();
      await tester.pump();
      expect(find.text('GEN 0'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('placing a live cell shows "Live cells drawn: 1" status text', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      // Set alive cells > 0 while generation = 0
      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.grid[10][10] = 1;
      });
      await tester.pump();
      // When aliveCount > 0 and generation == 0: status = "Live cells drawn: 1"
      expect(find.text('Live cells drawn: 1'), findsOneWidget);
      await _dispose(tester, testPlayKey);
    });

    testWidgets('clear() resets all game-end state fields', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(buildPlayScreen(key: testPlayKey));
      await tester.pump(const Duration(milliseconds: 500));

      testPlayKey.currentState!.setState(() {
        testPlayKey.currentState!.gameEndTitle = 'survived';
        testPlayKey.currentState!.gameEndMessage = 'msg';
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
      await _dispose(tester, testPlayKey);
    });
  });
}
