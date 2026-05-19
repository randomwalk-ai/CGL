import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishTutorial(int targetTab) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(initialTab: targetTab)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSlide(
                    visual: const _MiniDemo(frames: _drawing, crossAxisCount: 5),
                    title: "The Grid & Cells",
                    description:
                        "The universe is an infinite 2D grid. Each square is a 'cell' that can either be a Live cell (bright green) or an Empty cell (dark space).\n\nTap the squares to draw your starting community.",
                  ),
                  _buildRuleSummarySlide(),
                  _buildFinalSlide(),
                  const _InteractiveDemoSlide(),
                ],
              ),
            ),
            // Bottom Navigation Indicators
            if (_currentPage != 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _controller.jumpToPage(3), // Jump to last slide
                      child: const Text(
                        "SKIP",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: List.generate(4, (index) => _buildDot(index)),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text(
                        "NEXT",
                        style: TextStyle(color: green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 78), // To keep the layout balanced on the final slide
          ],
        ),
            if (Navigator.canPop(context))
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({required Widget visual, required String title, required String description}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            visual,
            const SizedBox(height: 40),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: green,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRuleSummarySlide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Rules of Life",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _ruleRow("SURVIVAL", "2 or 3 live neighbor cells", _survival, Icons.check_circle, green),
            _ruleRow("BIRTH", "Exactly 3 live neighbor cells", _reproduction, Icons.check_circle, green),
            _ruleRow("DEATH (Lonely)", "0 or 1 live neighbor cells", _underpopulation, Icons.cancel, Colors.redAccent),
            _ruleRow("DEATH (Crowded)", "> 3 live neighbor cells", _overpopulation, Icons.cancel, Colors.redAccent),
          ],
        ),
      ),
    );
  }


  Widget _ruleRow(String title, String condition, List<List<int>> frames, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _MiniDemo(frames: frames, crossAxisCount: 5, size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSlide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 100, color: green),
            const SizedBox(height: 40),
            const Text(
              "Ready to Evolve?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "We highly recommend reading the full 'Learn' guide to master the rules before playing!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? green : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _MiniDemo extends StatefulWidget {
  final List<List<int>> frames;
  final int crossAxisCount;
  final double size;

  const _MiniDemo({required this.frames, this.crossAxisCount = 5, this.size = 140});

  @override
  State<_MiniDemo> createState() => _MiniDemoState();
}

class _MiniDemoState extends State<_MiniDemo> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted && widget.frames.length > 1) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.frames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frames[_currentIndex];
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.crossAxisCount,
        ),
        itemCount: frame.length,
        itemBuilder: (context, index) {
          bool alive = frame[index] == 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: alive ? green : Colors.white.withOpacity(0.05),
              border: Border.all(color: alive ? green : Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: alive ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 8)] : [],
            ),
          );
        },
      ),
    );
  }
}

// Demo Patterns
const _drawing = [
  [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,1,1,1,0, 0,0,0,0,0],
];

const _underpopulation = [
  [0,0,0,0,0, 0,0,0,0,0, 0,0,1,1,0, 0,0,0,0,0, 0,0,0,0,0], // 2 cells
  [0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0], // Both die
];

const _survival = [
  [0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,0,0,0], // 2x2 block
  [0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,0,0,0], // Stays the same
];

const _overpopulation = [
  [0,0,0,0,0, 0,0,1,0,0, 0,1,1,1,0, 0,0,1,0,0, 0,0,0,0,0], // Plus shape
  [0,0,0,0,0, 0,1,1,1,0, 0,1,0,1,0, 0,1,1,1,0, 0,0,0,0,0], // Center dies
];

const _reproduction = [
  [0,0,0,0,0, 0,1,1,0,0, 0,1,0,0,0, 0,0,0,0,0, 0,0,0,0,0], // L shape
  [0,0,0,0,0, 0,1,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,0,0,0], // 4th cell spawns
];

class _InteractiveDemoSlide extends StatefulWidget {
  const _InteractiveDemoSlide();

  @override
  State<_InteractiveDemoSlide> createState() => _InteractiveDemoSlideState();
}

enum _DemoStep { pressPlay, watch, win }

class _InteractiveDemoSlideState extends State<_InteractiveDemoSlide> with SingleTickerProviderStateMixin {
  final int size = 10;
  late List<List<int>> grid;
  Timer? timer;
  _DemoStep _step = _DemoStep.pressPlay;
  late AnimationController _handController;
  bool _hasTapped = false;

  @override
  void initState() {
    super.initState();
    _handController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _reset();
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      grid = List.generate(size, (_) => List.filled(size, 0));
      // Pre-draw a simple pattern to evolve
      grid[4][4] = 1;
      grid[4][5] = 1;
      grid[5][4] = 1;
      _step = _DemoStep.pressPlay;
    });
  }

  void _play() {
    if (_step != _DemoStep.pressPlay) return;

    setState(() {
      _step = _DemoStep.watch;
    });

    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      final nextGrid = _nextGeneration();
      bool isSame = true;
      int aliveCount = 0;
      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          if (grid[i][j] != nextGrid[i][j]) {
            isSame = false;
          }
          if (nextGrid[i][j] == 1) aliveCount++;
        }
      }

      setState(() {
        grid = nextGrid;
      });

      if (isSame || aliveCount == 0) {
        timer?.cancel();
        setState(() {
          _step = _DemoStep.win;
        });
      }
    });
  }

  List<List<int>> _nextGeneration() {
    List<List<int>> newGrid = List.generate(size, (_) => List.filled(size, 0));
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        int n = _countNeighbors(x, y);
        if (grid[x][y] == 1) {
          if (n == 2 || n == 3) newGrid[x][y] = 1;
        } else {
          if (n == 3) newGrid[x][y] = 1;
        }
      }
    }
    return newGrid;
  }

  int _countNeighbors(int x, int y) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx == 0 && dy == 0) continue;
        int nx = x + dx;
        int ny = y + dy;
        if (nx >= 0 && ny >= 0 && nx < size && ny < size) {
          count += grid[nx][ny];
        }
      }
    }
    return count;
  }

  @override
  void dispose() {
    timer?.cancel();
    _handController.dispose();
    super.dispose();
  }

  String get _instructionText {
    switch (_step) {
      case _DemoStep.pressPlay:
        return "Tap the squares to draw a pattern, then press 'Play Demo'!";
      case _DemoStep.watch:
        return "Simulation is running... Observe how the cells evolve.";
      case _DemoStep.win:
        return "Simulation ended! It either stabilized or all cells became empty. Press 'Play Game' below to start.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Interactive Demo",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Text(
              _instructionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: size,
                  ),
                  itemCount: size * size,
                  itemBuilder: (context, index) {
                    int row = index ~/ size;
                    int col = index % size;
                    bool alive = grid[row][col] == 1;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!_hasTapped) {
                          setState(() {
                            _hasTapped = true;
                          });
                        }
                        if (_step == _DemoStep.watch) return;
                        setState(() {
                          grid[row][col] = 1 - grid[row][col];
                          _step = _DemoStep.pressPlay;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: alive ? green : Colors.white.withOpacity(0.05),
                          border: Border.all(color: alive ? green : Colors.white.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: alive
                              ? [BoxShadow(color: green.withOpacity(0.6), blurRadius: 8)]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
                if (!_hasTapped)
                  Positioned(
                    child: IgnorePointer(
                      child: SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, -0.3), end: const Offset(0, 0.3)).animate(
                          CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
                        ),
                        child: Icon(Icons.touch_app, size: 60, color: Colors.white.withOpacity(0.8)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 48,
            child: _step == _DemoStep.pressPlay
                ? ElevatedButton.icon(
                    onPressed: _play,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play Demo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: bg,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  )
                : _step == _DemoStep.win
                    ? ElevatedButton.icon(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 0)),
                            );
                          }
                        },
                        icon: const Icon(Icons.rocket_launch),
                        label: const Text("Play Game"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: bg,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
