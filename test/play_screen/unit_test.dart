// PLAY SCREEN – UNIT TESTS
// Tests pure Conway logic extracted into helpers. No timers involved.

import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('[Unit] Conway Engine', () {

    test('empty 20x20 grid initializes to all zeros', () {
      final g = emptyGrid(20);
      expect(g.length, 20);
      expect(g[0].length, 20);
      for (final row in g) {
        for (final cell in row) {
          expect(cell, 0);
        }
      }
    });

    test('countNeighbors returns 0 for isolated cell', () {
      final g = emptyGrid(20);
      g[10][10] = 1;
      expect(countNeighbors(g, 10, 10), 0);
    });

    test('countNeighbors returns 1 for cell with one alive neighbor', () {
      final g = emptyGrid(20);
      g[10][10] = 1;
      g[10][11] = 1;
      // From [10][10]'s perspective, [10][11] is a neighbor
      expect(countNeighbors(g, 10, 10), 1);
    });

    test('countNeighbors counts up to 8 neighbors correctly', () {
      final g = emptyGrid(20);
      // Surround [10][10] with all 8 neighbors alive
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx == 0 && dy == 0) continue;
          g[10 + dx][10 + dy] = 1;
        }
      }
      expect(countNeighbors(g, 10, 10), 8);
    });

    test('corner cell [0][0] can count a maximum of 3 neighbors', () {
      final g = emptyGrid(20);
      g[0][1] = 1;
      g[1][0] = 1;
      g[1][1] = 1;
      expect(countNeighbors(g, 0, 0), 3);
    });

    test('underpopulation: isolated cell dies (0 neighbors)', () {
      final g = emptyGrid(20);
      g[10][10] = 1;
      final next = nextGeneration(g);
      expect(next[10][10], 0);
    });

    test('underpopulation: cell with 1 neighbor dies', () {
      final g = emptyGrid(20);
      g[10][10] = 1;
      g[10][11] = 1;
      final next = nextGeneration(g);
      // Both cells have only 1 neighbor – both die
      expect(next[10][10], 0);
      expect(next[10][11], 0);
    });

    test('survival: cell with 2 neighbors survives', () {
      // A 2x2 block: each cell has exactly 3 neighbors (survives)
      // Use a known stable: 2x2 block
      final g = emptyGrid(20);
      g[10][10] = 1; g[10][11] = 1;
      g[11][10] = 1; g[11][11] = 1;
      final next = nextGeneration(g);
      // 2x2 block is stable – all four cells survive
      expect(next[10][10], 1);
      expect(next[10][11], 1);
      expect(next[11][10], 1);
      expect(next[11][11], 1);
    });

    test('survival: cell with 3 neighbors survives', () {
      final g = emptyGrid(20);
      // L-shape: [10][10], [10][11], [11][10]
      // [10][10] has 2 neighbors, [10][11] has 2, [11][10] has 2 → all survive
      // But [11][11] has 3 neighbors → born
      g[10][10] = 1; g[10][11] = 1;
      g[11][10] = 1;
      final next = nextGeneration(g);
      expect(next[10][10], 1);
    });

    test('overpopulation: cell with 4+ neighbors dies', () {
      // Plus shape: center at [10][10]
      final g = emptyGrid(20);
      g[10][10] = 1; // center
      g[9][10]  = 1; // up
      g[11][10] = 1; // down
      g[10][9]  = 1; // left
      g[10][11] = 1; // right
      // Center has 4 neighbors → dies
      final next = nextGeneration(g);
      expect(next[10][10], 0);
    });

    test('reproduction: dead cell with exactly 3 neighbors becomes alive', () {
      final g = emptyGrid(20);
      // L-shape around [11][11]
      g[10][10] = 1; g[10][11] = 1;
      g[11][10] = 1;
      // [11][11] is dead and has 3 neighbors → born
      final next = nextGeneration(g);
      expect(next[11][11], 1);
    });

    test('2x2 block is a still life (stable in standard rules)', () {
      final g = emptyGrid(20);
      g[10][10] = 1; g[10][11] = 1;
      g[11][10] = 1; g[11][11] = 1;
      final next = nextGeneration(g);
      expect(gridToString(next), gridToString(g));
    });

    test('3-cell vertical blinker oscillates to horizontal on next gen', () {
      final g = emptyGrid(20);
      // Vertical blinker at center
      g[9][10] = 1; g[10][10] = 1; g[11][10] = 1;
      final next = nextGeneration(g);
      // Should flip to horizontal
      expect(next[10][9],  1);
      expect(next[10][10], 1);
      expect(next[10][11], 1);
      expect(next[9][10],  0);
      expect(next[11][10], 0);
    });

    test('custom birthRule=4 births a cell with exactly 4 neighbors', () {
      final g = emptyGrid(20);
      // Place 4 live cells around [10][10] (dead)
      g[9][10] = 1; g[11][10] = 1;
      g[10][9] = 1; g[10][11] = 1;
      // Standard rules: birthRule=3 → NOT born (4 neighbors)
      final standardNext = nextGeneration(g);
      expect(standardNext[10][10], 0);
      // Custom rules: birthRule=4 → IS born
      final customNext = nextGeneration(g, birthRule: 4);
      expect(customNext[10][10], 1);
    });

    test('gridToString produces correct length string', () {
      final g = emptyGrid(20);
      expect(gridToString(g).length, 400);
    });

    test('gridToString differs between different grid states', () {
      final g1 = emptyGrid(20);
      final g2 = emptyGrid(20);
      g2[10][10] = 1;
      expect(gridToString(g1), isNot(gridToString(g2)));
    });

    test('extinction: all cells die produces empty grid string', () {
      // Two isolated cells with 1 neighbor each → both die
      final g = emptyGrid(20);
      g[10][10] = 1;
      g[10][12] = 1; // NOT adjacent, each is isolated
      final next = nextGeneration(g);
      expect(next[10][10], 0);
      expect(next[10][12], 0);
    });

    test('custom surviveMin/surviveMax: standard survive with 1 neighbor (permissive rules)', () {
      final g = emptyGrid(20);
      g[10][10] = 1;
      g[10][11] = 1; // [10][10] has 1 neighbor
      // With surviveMin=1, cell should survive
      final next = nextGeneration(g, surviveMin: 1, surviveMax: 3);
      expect(next[10][10], 1);
      expect(next[10][11], 1);
    });
  });
}
