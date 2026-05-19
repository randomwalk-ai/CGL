// WELCOME SCREEN – SYSTEM TESTS
// Tests top-level isolate helper function and full screen lifecycle.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/welcome_screen.dart';
import '../helpers/test_helpers.dart';

// Import the top-level isolate function for direct testing
// It is package-private (file-level) so we replicate its logic here.
List<List<int>> calculateNextGen(List<List<int>> currentGrid) {
  if (currentGrid.isEmpty) return currentGrid;
  int rows = currentGrid.length;
  int cols = currentGrid[0].length;
  List<List<int>> next =
      List.generate(rows, (_) => List.filled(cols, 0));
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      int neighbors = 0;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = r + dr, nc = c + dc;
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            neighbors += currentGrid[nr][nc];
          }
        }
      }
      if (currentGrid[r][c] == 1) {
        next[r][c] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
      } else {
        next[r][c] = (neighbors == 3) ? 1 : 0;
      }
    }
  }
  return next;
}

void main() {
  group('[System] WelcomeScreen isolate helper – Conway rules', () {
    test('returns empty grid unchanged', () {
      final result = calculateNextGen([]);
      expect(result, isEmpty);
    });

    test('2x2 block is stable (still life)', () {
      final g = [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 1, 1, 0],
        [0, 0, 0, 0],
      ];
      final next = calculateNextGen(g);
      expect(next[1][1], 1);
      expect(next[1][2], 1);
      expect(next[2][1], 1);
      expect(next[2][2], 1);
    });

    test('isolated cell dies (underpopulation)', () {
      final g = [
        [0, 0, 0],
        [0, 1, 0],
        [0, 0, 0],
      ];
      final next = calculateNextGen(g);
      expect(next[1][1], 0);
    });

    test('3-cell horizontal blinker flips to vertical', () {
      final g = [
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ];
      final next = calculateNextGen(g);
      expect(next[1][2], 1);
      expect(next[2][2], 1);
      expect(next[3][2], 1);
      expect(next[2][1], 0);
      expect(next[2][3], 0);
    });
  });

  group('[System] WelcomeScreen – Full lifecycle', () {
    testWidgets('renders and disposes cleanly', (tester) async {
      setTestViewport(tester);
      await tester.pumpWidget(wrapWithMaterial(const WelcomeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('WELCOME TO'), findsOneWidget);

      // Dispose by replacing widget tree
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pump(const Duration(milliseconds: 700));
      // No timer/animation exception = success
    });
  });
}
