import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/home_screen.dart';
import 'package:life_lab/play_screen.dart';
import 'package:life_lab/theme.dart';

// ---------------------------------------------------------------------------
// Viewport
// ---------------------------------------------------------------------------

/// Sets a large, fixed viewport so layout behaves deterministically.
void setTestViewport(WidgetTester tester, {double width = 1600, double height = 2400}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());
}

// ---------------------------------------------------------------------------
// MaterialApp wrappers
// ---------------------------------------------------------------------------

Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      brightness: Brightness.dark,
      sliderTheme: SliderThemeData(
        activeTrackColor: green,
        inactiveTrackColor: green.withOpacity(0.1),
        thumbColor: green,
        overlayColor: green.withOpacity(0.2),
        trackHeight: 6,
      ),
    ),
    home: child,
  );
}

// ---------------------------------------------------------------------------
// PlayScreen builder – builds the PlayScreen as it appears inside HomeScreen
// ---------------------------------------------------------------------------

Widget buildPlayScreen({
  GlobalKey<PlayScreenState>? key,
  int birthRule = 3,
  int surviveMin = 2,
  int surviveMax = 3,
  GlobalKey? gridKey,
  GlobalKey? playBtnKey,
  GlobalKey? ruleLabBtnKey,
}) {
  return wrapWithMaterial(
    Scaffold(
      body: PlayScreen(
        key: key,
        birthRule: birthRule,
        surviveMin: surviveMin,
        surviveMax: surviveMax,
        gridKey: gridKey ?? GlobalKey(),
        playBtnKey: playBtnKey ?? GlobalKey(),
        ruleLabBtnKey: ruleLabBtnKey ?? GlobalKey(),
        onHelpTap: () {},
        onRuleLabTap: () {},
      ),
    ),
  );
}

Widget buildHomeScreen({int initialTab = 0}) {
  return wrapWithMaterial(HomeScreen(initialTab: initialTab));
}

// ---------------------------------------------------------------------------
// Grid helpers
// ---------------------------------------------------------------------------

/// Returns the center [Offset] of a cell at [row],[col] in a 20x20 grid.
Offset cellOffset(WidgetTester tester, int row, int col) {
  // Find the first GridView.
  final RenderBox box = tester.renderObject(find.byType(GridView).first);
  final Size gridSize = box.size;
  final Offset topLeft = box.localToGlobal(Offset.zero);

  final double cellW = gridSize.width / 20;
  final double cellH = gridSize.height / 20;

  return Offset(
    topLeft.dx + col * cellW + cellW / 2,
    topLeft.dy + row * cellH + cellH / 2,
  );
}

/// Taps a single cell at [row],[col]. Only works when timer is NOT active.
Future<void> tapCell(WidgetTester tester, int row, int col) async {
  final offset = cellOffset(tester, row, col);
  await tester.tapAt(offset);
  await tester.pump();
}

Offset cellOffset10x10(WidgetTester tester, int row, int col) {
  final RenderBox box = tester.renderObject(find.byType(GridView));
  final Size gridSize = box.size;
  final Offset topLeft = box.localToGlobal(Offset.zero);

  final double cellW = gridSize.width / 10;
  final double cellH = gridSize.height / 10;

  return Offset(
    topLeft.dx + col * cellW + cellW / 2,
    topLeft.dy + row * cellH + cellH / 2,
  );
}

Future<void> tapCell10x10(WidgetTester tester, int row, int col) async {
  final offset = cellOffset10x10(tester, row, col);
  await tester.tapAt(offset);
  await tester.pump();
}

// ---------------------------------------------------------------------------
// Conway engine helpers (pure Dart – no widget needed)
// ---------------------------------------------------------------------------

List<List<int>> emptyGrid(int size) =>
    List.generate(size, (_) => List.filled(size, 0));

int countNeighbors(List<List<int>> grid, int x, int y) {
  final size = grid.length;
  int count = 0;
  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx == 0 && dy == 0) continue;
      int nx = x + dx, ny = y + dy;
      if (nx >= 0 && ny >= 0 && nx < size && ny < size) {
        count += grid[nx][ny];
      }
    }
  }
  return count;
}

List<List<int>> nextGeneration(
  List<List<int>> grid, {
  int birthRule = 3,
  int surviveMin = 2,
  int surviveMax = 3,
}) {
  final size = grid.length;
  final next = emptyGrid(size);
  for (int x = 0; x < size; x++) {
    for (int y = 0; y < size; y++) {
      final n = countNeighbors(grid, x, y);
      if (grid[x][y] == 1) {
        next[x][y] = (n >= surviveMin && n <= surviveMax) ? 1 : 0;
      } else {
        next[x][y] = (n == birthRule) ? 1 : 0;
      }
    }
  }
  return next;
}

String gridToString(List<List<int>> g) =>
    g.expand((row) => row).join('');
