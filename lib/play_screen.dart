import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';

class PlayScreen extends StatefulWidget {
  final int birthRule;
  final int surviveMin;
  final int surviveMax;
  final GlobalKey gridKey;
  final GlobalKey playBtnKey;
  final GlobalKey ruleLabBtnKey;
  final VoidCallback onHelpTap;
  final VoidCallback onRuleLabTap;

  const PlayScreen({
    super.key,
    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
    required this.gridKey,
    required this.playBtnKey,
    required this.ruleLabBtnKey,
    required this.onHelpTap,
    required this.onRuleLabTap,
  });

  @override
  State<PlayScreen> createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin {
  final size = 20;
  late List<List<int>> grid;
  late List<List<int>> _initialGridSnapshot;
  Timer? timer;
  int generation = 0;

  String? gameEndTitle;
  String? gameEndMessage;
  bool isWin = false;
  bool _showOverlay = false;
  List<String> history = [];

  bool _isSpeedToggled = false; // For tapping
  bool _isSpeedHeld = false; // For holding
  int _initialCellsCount = 0;

  int _highScore = 0;
  bool _hasShownHand = false;

  final GlobalKey _speedBtnKey = GlobalKey();
  final GlobalKey _statusAreaKey = GlobalKey();
  int _tutorialStep = -1;
  Timer? _badgeTimer;

  late AnimationController _pulseController;

  int _genTapCount = 0;
  Timer? _genTapTimer;

  bool _showResetText = false;
  bool _hasShownResetText = false;
  bool _hasShownRestartText = false;
  Timer? _resetTextTimer;

  final LayerLink _gridLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    grid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );
    _initialGridSnapshot = List.generate(size, (_) => List.filled(size, 0));
    _loadHighScore();
    _checkPlayTutorial();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    timer?.cancel();
    _badgeTimer?.cancel();
    _genTapTimer?.cancel();
    _resetTextTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPlayTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    
    bool shown = prefs.getBool('playScreenTutorialShown') ?? false;
    if (!shown) {
      setState(() {
        _tutorialStep = 0;
      });
    }
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
      _hasShownHand = prefs.getBool('hasShownHandAnimation') ?? false;
    });
  }

  void _triggerOverlay() {
    setState(() {
      _showOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() => _showOverlay = false);
      }
    });
  }

  void start() {
    timer?.cancel();

    if (_tutorialStep != -1) {
      if (_tutorialStep == 1) setState(() => _tutorialStep = 2);
      else if (_tutorialStep == 6) setState(() => _tutorialStep = 7);
      else if (_tutorialStep == 9) setState(() => _tutorialStep = 10);
      else if (_tutorialStep == 12) setState(() => _tutorialStep = 13);
      else if (_tutorialStep == 15) setState(() => _tutorialStep = 16);
    }

    setState(() {
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      _showOverlay = false;
    });

    int aliveInit = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] == 1) aliveInit++;
      }
    }
    if (aliveInit == 0) {
      return;
    }
    _initialCellsCount = aliveInit;
    _initialGridSnapshot = List.generate(size, (x) => List.from(grid[x]));

    history.clear();
    history.add(_gridToString(grid));

    _setTimer();

    if (!_hasShownRestartText) {
      _hasShownRestartText = true;
      setState(() => _showResetText = true);
      _resetTextTimer?.cancel();
      _resetTextTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showResetText = false);
      });
    }
  }

  void tryAgain() {
    // Completely reset everything and bring back the "Play" button
    clear();
  }

  void _setTimer() {
    timer?.cancel();
    // Speed is 2x if either toggled on or currently held down
    bool isFast = _isSpeedToggled || _isSpeedHeld;
    int speed = isFast ? 200 : 500;

    timer = Timer.periodic(
      Duration(milliseconds: speed),
      (_) => _doTick(),
    );
  }

  void _updateSpeed() {
    if (timer != null && timer!.isActive) {
      _setTimer();
    }
  }

  void _doTick() {
    List<List<int>> nextGrid = nextGeneration();

    bool isSame = true;
    int aliveCount = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] != nextGrid[x][y]) isSame = false;
        if (nextGrid[x][y] == 1) aliveCount++;
      }
    }

    bool wasEnded = gameEndTitle != null;
    setState(() {
      if (!wasEnded) {
        generation++;
      }
      grid = nextGrid;
    });

    String nextStr = _gridToString(nextGrid);
    bool isOscillating = !isSame && history.contains(nextStr);

    if (aliveCount == 0) {
      bool isNew = gameEndTitle == null;
      if (isNew) {
        pause();
        setState(() {
          if (_tutorialStep == 3) _tutorialStep = 4;
          gameEndTitle = "Your pattern failed";
          gameEndMessage = "Started with $_initialCellsCount cells, but all died after $generation generations.";
          isWin = false;
        });
        _triggerOverlay();
      }
    } else if (isSame) {
      bool isNew = gameEndTitle == null;
      if (isNew) {
        pause();
        setState(() {
          if (_tutorialStep == 3) _tutorialStep = 4;
          // High Score Logic: Only update on win condition after tutorial is done
          if (_tutorialStep == -1 && aliveCount > _highScore) {
            _highScore = aliveCount;
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt('highScore', _highScore);
            });
          }
          gameEndTitle = "Your pattern survived with $aliveCount live cells";
          gameEndMessage = "Started with $_initialCellsCount cells. Stabilized after $generation generations.";
          isWin = true;
        });
        _triggerOverlay();
      }
    } else {
      if (isOscillating) {
        bool isNew = gameEndTitle == null;
        if (isNew) {
          // Intentionally NOT pausing here so the loop continues animating!
          setState(() {
            if (_tutorialStep == 3) _tutorialStep = 4;
            // High Score Logic: Also update on loop condition after tutorial is done
            if (_tutorialStep == -1 && aliveCount > _highScore) {
              _highScore = aliveCount;
              SharedPreferences.getInstance().then((prefs) {
                prefs.setInt('highScore', _highScore);
              });
            }
            gameEndTitle = "Your pattern is looping with $aliveCount live cells";
            gameEndMessage = "Started with $_initialCellsCount cells. Entered a loop after $generation generations.";
            isWin = true;
          });
          _triggerOverlay();
        }
      }
      history.add(nextStr);
      if (history.length > 25) {
        history.removeAt(0);
      }
    }
  }

  void pause() {
    timer?.cancel();
  }

  Future<void> _shareStats(int aliveCount, double growthMultiplier) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 800.0;
    const height = 850.0;
    
    // Background
    final bgPaint = Paint()..color = bg;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Card Background
    final cardPaint = Paint()..color = card;
    final rrect = RRect.fromLTRBR(40, 40, width - 40, height - 40, const Radius.circular(30));
    canvas.drawRRect(rrect, cardPaint);
    
    // Border for Card
    final cardBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, cardBorderPaint);

    // Title
    const titleSpan = TextSpan(
      text: "LIFE LAB",
      style: TextStyle(color: green, fontSize: 50, fontWeight: FontWeight.bold, letterSpacing: 4),
    );
    final titlePainter = TextPainter(text: titleSpan, textDirection: TextDirection.ltr)..layout();
    titlePainter.paint(canvas, Offset((width - titlePainter.width) / 2, 60));

    // Result Title
    final resultSpan = TextSpan(
      text: isWin ? "SURVIVED" : "FAILED",
      style: TextStyle(color: isWin ? green : Colors.redAccent, fontSize: 32, fontWeight: FontWeight.w200, letterSpacing: 8),
    );
    final resultPainter = TextPainter(text: resultSpan, textDirection: TextDirection.ltr)..layout();
    resultPainter.paint(canvas, Offset((width - resultPainter.width) / 2, 115));

    // Draw Grids Function
    void drawGrid(Canvas c, Offset offset, double gridSize, List<List<int>> gridData, String label) {
       final labelSpan = TextSpan(text: label, style: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2));
       final labelPainter = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
       labelPainter.paint(c, Offset(offset.dx + (gridSize - labelPainter.width) / 2, offset.dy - 35));

       final cellSize = gridSize / size;
       final cellPaintAlive = Paint()..color = green;
       final cellPaintDead = Paint()..color = Colors.white.withOpacity(0.05);
       
       final borderPaintDead = Paint()..color = Colors.white.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1.0;
       final borderPaintAlive = Paint()..color = green..style = PaintingStyle.stroke..strokeWidth = 1.0;

       for (int x = 0; x < size; x++) {
         for (int y = 0; y < size; y++) {
           // Adding a small gap to separate the cells and reveal the dark background as grid lines
           final gap = 1.5;
           final rect = RRect.fromRectAndRadius(
             Rect.fromLTWH(
               offset.dx + y * cellSize + gap, 
               offset.dy + x * cellSize + gap, 
               cellSize - gap * 2, 
               cellSize - gap * 2
             ),
             const Radius.circular(2), // Matches the slightly rounded corners in the app
           );
           final isAlive = gridData[x][y] == 1;
           c.drawRRect(rect, isAlive ? cellPaintAlive : cellPaintDead);
           c.drawRRect(rect, isAlive ? borderPaintAlive : borderPaintDead);
         }
       }
    }

    // Grids side by side
    const gridRenderSize = 310.0;
    drawGrid(canvas, const Offset(70, 180), gridRenderSize, _initialGridSnapshot, "INITIAL");
    drawGrid(canvas, const Offset(width - 70 - gridRenderSize, 180), gridRenderSize, grid, "FINAL");

    // Stats Box Details
    Color growthColor = growthMultiplier >= 2.0 ? Colors.amber : (growthMultiplier >= 1.0 ? green : Colors.redAccent);
    String badge = growthMultiplier >= 2.0 ? "EXCELLENT" : (growthMultiplier >= 1.0 ? "GREAT" : "SURVIVING");
    if (!isWin) badge = "DIED";
    Color finalBadgeColor = isWin ? growthColor : Colors.redAccent;

    void drawStat(Canvas c, Offset center, double w, String label, String val, Color valColor, String emoji) {
      final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: w, height: 100), const Radius.circular(20));
      c.drawRRect(rect, Paint()..color = Colors.white.withOpacity(0.05));
      
      final labelSpan = TextSpan(text: "$emoji  $label", style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5));
      final labelP = TextPainter(text: labelSpan, textDirection: TextDirection.ltr)..layout();
      labelP.paint(c, Offset(center.dx - labelP.width / 2, center.dy - 28));

      final valSpan = TextSpan(text: val, style: TextStyle(color: valColor, fontSize: 32, fontWeight: FontWeight.bold));
      final valP = TextPainter(text: valSpan, textDirection: TextDirection.ltr)..layout();
      valP.paint(c, Offset(center.dx - valP.width / 2, center.dy + 2));
    }

    // Draw row 1
    drawStat(canvas, const Offset(width / 2 - 240, 560), 220, "START", "$_initialCellsCount", Colors.white, "🥚");
    drawStat(canvas, const Offset(width / 2, 560), 220, "GENS", "$generation", Colors.white, "⏳");
    drawStat(canvas, const Offset(width / 2 + 240, 560), 220, "FINAL", "$aliveCount", Colors.white, "🧬");
    // Draw row 2
    drawStat(canvas, const Offset(width / 2 - 180, 680), 340, "GROWTH", "${growthMultiplier.toStringAsFixed(1)}x", growthColor, "📈");
    drawStat(canvas, const Offset(width / 2 + 180, 680), 340, "BADGE", badge, finalBadgeColor, "🏅");

    // Footer
    const footerSpan = TextSpan(
      text: "randomwalk.ai/lifelab",
      style: TextStyle(color: Colors.grey, fontSize: 18, letterSpacing: 1.2),
    );
    final footerPainter = TextPainter(text: footerSpan, textDirection: TextDirection.ltr)..layout();
    footerPainter.paint(canvas, Offset((width - footerPainter.width) / 2, height - 80));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();

    await Share.shareXFiles(
      [XFile.fromData(bytes, mimeType: 'image/png', name: 'life_lab_stats.png')],
      text: 'I reached generation $generation in Life Lab with $aliveCount cells! Can you beat my pattern?',
    );
  }

  void clear({bool andResetHighScore = false}) {
    timer?.cancel();
    _badgeTimer?.cancel();

    if (andResetHighScore) {
      _resetHighScore();
    }

    setState(() {
      _showResetText = false;
      _hasShownResetText = false;
      _hasShownRestartText = false;
      _resetTextTimer?.cancel();
      if (!andResetHighScore && _tutorialStep != -1) {
        if (_tutorialStep == 4) _tutorialStep = 5;
        else if (_tutorialStep == 7) _tutorialStep = 8;
        else if (_tutorialStep == 10) _tutorialStep = 11;
        else if (_tutorialStep == 13) _tutorialStep = 14;
        else if (_tutorialStep == 16) _tutorialStep = 17;
      }
      generation = 0;
      gameEndTitle = null;
      gameEndMessage = null;
      isWin = false;
      _showOverlay = false;
      history.clear();
      _initialCellsCount = 0;
      
      _isSpeedToggled = false;
      _isSpeedHeld = false;

      grid = List.generate(
        size,
        (_) => List.filled(size, 0),
      );
      _initialGridSnapshot = List.generate(size, (_) => List.filled(size, 0));
    });
  }

  Future<void> _resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', 0);
    await prefs.setBool('playScreenTutorialShown', false);
    // Let's proactively clear common keys for your Welcome/Learn Screen
    await prefs.setBool('learnScreenTutorialShown', false);
    await prefs.setBool('welcomeTutorialShown', false);
    await prefs.setBool('isFirstTime', true);
    if (mounted) {
      setState(() {
        _highScore = 0;
        _tutorialStep = 0; // Instantly restart tutorial on this screen
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("High Score & Tutorials Reset!"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _gridToString(List<List<int>> g) {
    return g.expand((row) => row).join('');
  }

  List<List<int>> nextGeneration() {
    List<List<int>> newGrid = List.generate(
      size,
      (_) => List.filled(size, 0),
    );

    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        int n = countNeighbors(x, y);
        if (grid[x][y] == 1) {
          if (n >= widget.surviveMin && n <= widget.surviveMax) {
            newGrid[x][y] = 1;
          }
        } else {
          if (n == widget.birthRule) {
            newGrid[x][y] = 1;
          }
        }
      }
    }

    return newGrid;
  }

  int countNeighbors(int x, int y) {
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

  void _checkTutorialDrawPhase() {
    int aliveCount = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] == 1) aliveCount++;
      }
    }
    if (_tutorialStep == 0) {
      if (grid[8][9] == 1 && grid[8][10] == 1 && grid[9][8] == 1 && grid[9][9] == 1 && grid[10][9] == 1 && aliveCount == 5) _tutorialStep = 1;
    } else if (_tutorialStep == 5) {
      if (grid[9][9] == 1 && aliveCount == 1) _tutorialStep = 6;
    } else if (_tutorialStep == 8) {
      if (grid[9][9] == 1 && grid[9][10] == 1 && grid[10][9] == 1 && grid[10][10] == 1 && aliveCount == 4) _tutorialStep = 9;
    } else if (_tutorialStep == 11) {
      bool is4x4BoxDrawComplete = true;
      for (int r = 8; r <= 11; r++) {
        for (int c = 8; c <= 11; c++) {
          if (grid[r][c] != 1) {
            is4x4BoxDrawComplete = false;
          }
        }
      }
      if (is4x4BoxDrawComplete && aliveCount == 16) _tutorialStep = 12;
    } else if (_tutorialStep == 14) {
      if (grid[9][9] == 1 && grid[10][9] == 1 && grid[10][10] == 1 && aliveCount == 3) _tutorialStep = 15;
    }
  }

  Widget _buildResetButton() {
    if (_tutorialStep != -1) return const SizedBox.shrink();

    bool isRunning = timer != null && timer!.isActive;
    String text = isRunning ? "Restart" : "Reset";
    IconData icon = isRunning ? Icons.restart_alt : Icons.refresh;

    return GestureDetector(
      onTap: () {
        clear();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: card.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              if (_showResetText) ...[
                const SizedBox(width: 4),
                Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int aliveCount = 0;
    for (int x = 0; x < size; x++) {
      for (int y = 0; y < size; y++) {
        if (grid[x][y] == 1) aliveCount++;
      }
    }
    String status = aliveCount == 0 ? "All cells empty" : "Active";

    bool isRunning = timer != null && timer!.isActive;
    double growthMultiplier = _initialCellsCount > 0 ? (aliveCount / _initialCellsCount) : 0.0;
    Color growthColor = growthMultiplier >= 2.0 ? Colors.amber : (growthMultiplier >= 1.0 ? green : Colors.redAccent);
    IconData growthIcon = growthMultiplier >= 2.0 ? Icons.local_fire_department : (growthMultiplier >= 1.0 ? Icons.trending_up : Icons.trending_down);
    String liveBadgeText = growthMultiplier >= 2.0 ? "EXCELLENT" : (growthMultiplier >= 1.0 ? "GREAT" : "SURVIVING");
    if (gameEndTitle != null && !isWin) liveBadgeText = "DIED";
    Color finalBadgeColor = (gameEndTitle != null && !isWin) ? Colors.redAccent : growthColor;
    
    String badgePrefix = " You did ";
    if (liveBadgeText == "SURVIVING") badgePrefix = " You are ";
    if (liveBadgeText == "DIED") badgePrefix = " You ";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        key: _statusAreaKey,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.transparent, width: 2),
                          boxShadow: const [],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "LIFE LAB",
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Tooltip(
                                      message: "Your highscore is: $_highScore",
                                      triggerMode: TooltipTriggerMode.tap,
                                      preferBelow: true,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.military_tech, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$_highScore",
                                            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: const [],
                                      ),
                                      child: IconButton(
                                        key: widget.ruleLabBtnKey,
                                        icon: Icon(Icons.tune, color: (isRunning || _tutorialStep != -1) ? Colors.grey : green),
                                        onPressed: (isRunning || _tutorialStep != -1) ? null : () {
                                          widget.onRuleLabTap();
                                        },
                                        tooltip: "Experiment with Rules",
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.help_outline, color: (isRunning || _tutorialStep != -1) ? Colors.grey : green),
                                      onPressed: (isRunning || _tutorialStep != -1) ? null : widget.onHelpTap,
                                      tooltip: "Tutorial",
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        if (_tutorialStep != -1) return;
                                        _genTapCount++;
                                        _genTapTimer?.cancel();
                                        if (_genTapCount >= 5) {
                                          _genTapCount = 0;
                                          clear(andResetHighScore: true);
                                        } else {
                                          _genTapTimer = Timer(const Duration(milliseconds: 500), () => _genTapCount = 0);
                                        }
                                      },
                                      child: Text(
                                        "GEN $generation",
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 76,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        generation == 0 
                                            ? "Live cells drawn: $aliveCount"
                                            : "Started: $_initialCellsCount   •   Current: $aliveCount",
                                        style: const TextStyle(
                                            color: green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      if (generation > 0 && _initialCellsCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: growthColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: growthColor.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(growthIcon, color: growthColor, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${growthMultiplier.toStringAsFixed(1)}x",
                                                style: TextStyle(color: growthColor, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (gameEndMessage != null) ...[
                                    const SizedBox(height: 4),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: gameEndMessage!),
                                          TextSpan(text: badgePrefix),
                                          TextSpan(
                                            text: liveBadgeText,
                                            style: TextStyle(color: finalBadgeColor, fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: "!"),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double gridSize = constraints.maxWidth < constraints.maxHeight
                            ? constraints.maxWidth
                            : constraints.maxHeight;
                        double cellWidth = gridSize / size;

                        double gridTop = (constraints.maxHeight - gridSize) / 2;
                        double gridRight = (constraints.maxWidth - gridSize) / 2;

                        return Center(
                          child: CompositedTransformTarget(
                            link: _gridLink,
                            child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: gridSize,
                            height: gridSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.transparent, width: 2),
                              boxShadow: const [],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onPanUpdate: (details) {
                                    if (timer != null && timer!.isActive) return;
                                    if (gameEndTitle != null) return;
                                    int col = (details.localPosition.dx / cellWidth).floor();
                                    int row = (details.localPosition.dy / cellWidth).floor();
                                    if (row >= 0 && row < size && col >= 0 && col < size) {
                                      if (_tutorialStep != -1) {
                                        if (_tutorialStep == 0 && !((row == 8 && col == 9) || (row == 8 && col == 10) || (row == 9 && col == 8) || (row == 9 && col == 9) || (row == 10 && col == 9))) return;
                                        if (_tutorialStep == 5 && (row != 9 || col != 9)) return;
                                        if (_tutorialStep == 8 && !(row >= 9 && row <= 10 && col >= 9 && col <= 10)) return;
                                        if (_tutorialStep == 11 && !((row == 8 && col == 9) || (row == 9 && col >= 8 && col <= 10) || (row == 10 && col == 9))) return;
                                        if (_tutorialStep == 14 && !((row == 9 && col == 9) || (row == 10 && col == 9) || (row == 10 && col == 10))) return;
                                        if ([1, 2, 3, 4, 6, 7, 9, 10, 12, 13, 15, 16, 17].contains(_tutorialStep)) return;
                                      }
                                      if (grid[row][col] == 0) {
                                        setState(() {
                                          grid[row][col] = 1;
                                          gameEndTitle = null;
                                          gameEndMessage = null;
                                          isWin = false;
                                          _showOverlay = false;
                                          history.clear();
                                          _checkTutorialDrawPhase();
                                          if (_tutorialStep == -1 && !_hasShownResetText) {
                                            _hasShownResetText = true;
                                            _showResetText = true;
                                            _resetTextTimer?.cancel();
                                            _resetTextTimer = Timer(const Duration(seconds: 2), () {
                                              if (mounted) setState(() => _showResetText = false);
                                            });
                                          }
                                        });
                                      }
                                    }
                                  },
                                  child: GridView.builder(
                                    key: widget.gridKey,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: size * size,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: size,
                                    ),
                                    itemBuilder: (context, index) {
                                      int row = index ~/ size;
                                      int col = index % size;
                                      bool alive = grid[row][col] == 1;
                                      
                                      bool isTutorialTarget = false;
                                      if (_tutorialStep == 0) isTutorialTarget = ((row == 8 && col == 9) || (row == 8 && col == 10) || (row == 9 && col == 8) || (row == 9 && col == 9) || (row == 10 && col == 9));
                                      else if (_tutorialStep == 5) isTutorialTarget = (row == 9 && col == 9);
                                      else if (_tutorialStep == 8) isTutorialTarget = ((row >= 9 && row <= 10) && (col >= 9 && col <= 10));
                                      else if (_tutorialStep == 11) isTutorialTarget = (row >= 8 && row <= 11 && col >= 8 && col <= 11);
                                      else if (_tutorialStep == 14) isTutorialTarget = ((row == 9 && col == 9) || (row == 10 && col == 9) || (row == 10 && col == 10));
                                      isTutorialTarget = isTutorialTarget && !alive;

                                      return GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (timer != null && timer!.isActive) return;
                                          if (gameEndTitle != null) return;
                                          if (_tutorialStep != -1) {
                                            if (_tutorialStep == 0 && !((row == 8 && col == 9) || (row == 8 && col == 10) || (row == 9 && col == 8) || (row == 9 && col == 9) || (row == 10 && col == 9))) return;
                                            if (_tutorialStep == 5 && (row != 9 || col != 9)) return;
                                            if (_tutorialStep == 8 && !(row >= 9 && row <= 10 && col >= 9 && col <= 10)) return;
                                            if (_tutorialStep == 11 && !(row >= 8 && row <= 11 && col >= 8 && col <= 11)) return;
                                            if (_tutorialStep == 14 && !((row == 9 && col == 9) || (row == 10 && col == 9) || (row == 10 && col == 10))) return;
                                            if ([1, 2, 3, 4, 6, 7, 9, 10, 12, 13, 15, 16, 17].contains(_tutorialStep)) return;
                                          }
                                          setState(() {
                                            grid[row][col] = 1 - grid[row][col];
                                            gameEndTitle = null;
                                            gameEndMessage = null;
                                            isWin = false;
                                            _showOverlay = false;
                                            history.clear();
                                            _checkTutorialDrawPhase();
                                            if (_tutorialStep == -1 && !_hasShownHand) {
                                              _hasShownHand = true;
                                              SharedPreferences.getInstance().then((p) => p.setBool('hasShownHandAnimation', true));
                                            }
                                            if (_tutorialStep == -1 && !_hasShownResetText) {
                                              _hasShownResetText = true;
                                              _showResetText = true;
                                              _resetTextTimer?.cancel();
                                              _resetTextTimer = Timer(const Duration(seconds: 2), () {
                                                if (mounted) setState(() => _showResetText = false);
                                              });
                                            }
                                          });
                                        },
                                        child: isTutorialTarget
                                            ? AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  double val = _pulseController.value;
                                                  return Transform.scale(
                                                    scale: 1.0 + (val * 0.25),
                                                    child: Container(
                                                      margin: const EdgeInsets.all(1.5),
                                                      decoration: BoxDecoration(
                                                        color: green.withOpacity(0.1 + val * 0.25),
                                                        border: Border.all(
                                                          color: green.withOpacity(0.2 + val * 0.3),
                                                          width: 1.0 + val * 1.0,
                                                        ),
                                                        borderRadius: BorderRadius.circular(4),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: green.withOpacity(0.1 + val * 0.2),
                                                            blurRadius: 4 + val * 6,
                                                            spreadRadius: val * 1,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                margin: const EdgeInsets.all(1.5),
                                                decoration: BoxDecoration(
                                                  color: alive ? green : Colors.white.withOpacity(0.05),
                                                  border: Border.all(color: alive ? green : Colors.white.withOpacity(0.1)),
                                                  borderRadius: BorderRadius.circular(4),
                                                  boxShadow: alive
                                                      ? [
                                                          BoxShadow(
                                                            color: green.withOpacity(.5),
                                                            blurRadius: 8,
                                                          )
                                                        ]
                                                      : [],
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                                if (_tutorialStep == -1 && aliveCount == 0 && !isRunning && gameEndTitle == null && !_hasShownHand)
                                  IgnorePointer(
                                    child: AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: 1.0 - (_pulseController.value * 0.2),
                                          child: child,
                                        );
                                      },
                                      child: Icon(Icons.touch_app, size: 60, color: Colors.white.withOpacity(0.5)),
                                    ),
                                  ),
                                IgnorePointer(
                                  ignoring: true,
                                  child: AnimatedOpacity(
                                    opacity: _showOverlay ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 400),
                                    child: AnimatedScale(
                                      scale: _showOverlay ? 1.0 : 0.9,
                                      duration: const Duration(milliseconds: 600),
                                      curve: Curves.easeOutExpo,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.02), // Extremely subtle tint
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isWin ? "WIN" : "LOSE",
                                                  style: TextStyle(color: isWin ? green : Colors.redAccent, fontSize: 40, fontWeight: FontWeight.w200, letterSpacing: 10),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  isWin && growthMultiplier >= 2.0
                                                      ? "Excellent!"
                                                      : isWin && growthMultiplier >= 1.0
                                                          ? "Great Job! Keep Going!"
                                                          : "Try to keep more cells alive\nto get a better highscore!",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: Center(
                      child: gameEndTitle != null
                          ? Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isWin
                                          ? green.withOpacity(0.1)
                                          : Colors.redAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isWin
                                            ? green.withOpacity(0.3)
                                            : Colors.redAccent.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          gameEndTitle!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isWin ? green : Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isWin) ...[
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _shareStats(aliveCount, growthMultiplier),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: green.withOpacity(0.1),
                                        foregroundColor: green,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: green.withOpacity(0.3)),
                                        ),
                                      ),
                                      child: const Icon(Icons.share),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Draw your starting cells & press Play!",
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.egg_alt, color: green, size: 14),
                                    SizedBox(width: 4),
                                    Text("Start Small", style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.grey, size: 12),
                                    SizedBox(width: 8),
                                    Icon(Icons.all_out, color: Colors.amber, size: 14),
                                    SizedBox(width: 4),
                                    Text("Grow Huge", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: actionButton(
                          gameEndTitle != null ? "Play Again" : (_tutorialStep == 17 ? "Finish" : "Play"),
                          gameEndTitle != null ? Icons.replay : (_tutorialStep == 17 ? Icons.check : Icons.play_arrow),
                          gameEndTitle != null 
                              ? tryAgain 
                              : (_tutorialStep == 17
                                  ? () {
                                      setState(() {
                                        _tutorialStep = -1;
                                        grid = List.generate(size, (_) => List.filled(size, 0));
                                        history.clear();
                                      });
                                      SharedPreferences.getInstance().then((p) => p.setBool('playScreenTutorialShown', true));
                                    }
                                  : ((timer != null && timer!.isActive) || 
                                     (_tutorialStep != -1 && !([1, 6, 9, 12, 15].contains(_tutorialStep))) ||
                                     aliveCount == 0
                                      ? null 
                                      : start)),
                          isPrimary: true,
                          isTutorialGlow: [1, 4, 6, 7, 9, 10, 12, 13, 15, 16, 17].contains(_tutorialStep),
                          key: widget.playBtnKey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (!isRunning || (_tutorialStep != -1 && _tutorialStep != 2)) return;
                          setState(() {
                            _isSpeedToggled = !_isSpeedToggled;
                            if (_tutorialStep == 2) _tutorialStep = 3;
                          });
                          _updateSpeed();
                        },
                        onLongPressStart: (_) {
                          if (!isRunning || (_tutorialStep != -1 && _tutorialStep != 2)) return;
                          setState(() {
                            _isSpeedHeld = true;
                            if (_tutorialStep == 2) _tutorialStep = 3;
                          });
                          _updateSpeed();
                        },
                        onLongPressEnd: (_) {
                          if (!isRunning && _tutorialStep != -1) return;
                          setState(() => _isSpeedHeld = false);
                          _updateSpeed();
                        },
                        child: AnimatedContainer(
                          key: _speedBtnKey,
                          duration: const Duration(milliseconds: 150),
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: !isRunning ? card.withOpacity(0.5) : ((_isSpeedToggled || _isSpeedHeld) ? green : card),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isRunning && (_isSpeedToggled || _isSpeedHeld) ? green : Colors.white.withOpacity(0.1)),
                            boxShadow: _tutorialStep == 2 ? [BoxShadow(color: green.withOpacity(0.8), blurRadius: 25, spreadRadius: 6)] : [],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.bolt,
                              color: !isRunning ? Colors.white54 : ((_isSpeedToggled || _isSpeedHeld) ? bg : Colors.white),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        _buildInlineTutorial(aliveCount),
        CompositedTransformFollower(
          link: _gridLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          offset: const Offset(0, -8),
          child: _buildResetButton(),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildInlineTutorial(int aliveCount) {
    if (_tutorialStep < 0) return const SizedBox.shrink();

    String title = "";
    String desc = "";
    bool isTop = true;

    switch (_tutorialStep) {
      case 0:
        title = "Aim of the Game";
        desc = "Make your cells survive and grow!\nTap the 5 blinking cells to draw an 'R-pentomino'.";
        isTop = false;
        break;
      case 1:
        title = "1. Evolve";
        desc = "Press the glowing Play button below to bring your cells to life!";
        isTop = true;
        break;
      case 2:
        title = "2. Speed Control";
        desc = "Simulation running too slow? Tap the glowing lightning button below to toggle 2x speed!";
        isTop = true;
        break;
      case 3:
        title = "3. Earn Your Badge!";
        desc = "Watch the Growth stat above!\n🔴 DIED / SURVIVING (<1.0x)\n🟢 GREAT (1.0x-1.9x)\n🟠 EXCELLENT (2.0x+)\nKeep them alive to set a High Score! (Wait for run to end)";
        isTop = false;
        break;
      case 4:
        title = "4. Clear & Reset";
        desc = "Awesome run! Tap 'Play Again' below to clear the grid and learn the exact rules of Life.";
        isTop = true;
        break;
      case 5:
        title = "Rule 1: Isolation";
        desc = "Draw a single isolated cell. Tap the blinking square in the center.";
        isTop = false;
        break;
      case 6:
        title = "Rule 1: Isolation";
        desc = "Press the glowing Play button! A cell with fewer than 2 neighbors dies of loneliness.";
        isTop = true;
        break;
      case 7:
        title = "Rule 1: Isolation";
        desc = "It died! Tap 'Play Again' below to clear the grid for the next rule.";
        isTop = true;
        break;
      case 8:
        title = "Rule 2: Balance";
        desc = "Draw a 2x2 square by tapping the 4 blinking cells. Cells with 2 or 3 neighbors stay alive.";
        isTop = false;
        break;
      case 9:
        title = "Rule 2: Balance";
        desc = "Press Play! Watch it stabilize and survive perfectly.";
        isTop = true;
        break;
      case 10:
        title = "Rule 2: Balance";
        desc = "It survived! A stable shape is called a 'Still Life'. Tap 'Play Again'.";
        isTop = true;
        break;
      case 11:
        title = "Rule 3: Crowding";
        desc = "Draw a solid 4x4 box using the 16 blinking cells.";
        isTop = false;
        break;
      case 12:
        title = "Rule 3: Crowding";
        desc = "Press Play! The middle and edge cells have too many neighbors, which is too crowded.";
        isTop = true;
        break;
      case 13:
        title = "Rule 3: Crowding";
        desc = "They died of overpopulation, leaving only the 4 corners! Tap 'Play Again'.";
        isTop = true;
        break;
      case 14:
        title = "Rule 4: Reproduction";
        desc = "Draw an 'L' shape (3 cells). Exactly 3 neighbors bring an empty space to life!";
        isTop = false;
        break;
      case 15:
        title = "Rule 4: Reproduction";
        desc = "Press Play to watch the 4th cell spawn to complete the square!";
        isTop = true;
        break;
      case 16:
        title = "Rule 4: Reproduction";
        desc = "A new cell was born! Tap 'Play Again'.";
        isTop = true;
        break;
      case 17:
        title = "You're Ready!";
        desc = "Find stable patterns or loops to win! But if all cells die, you lose.\n\nTap 'Finish' to complete the tutorial.";
        isTop = true;
        break;
    }

    return Positioned(
      top: isTop ? 20 : null,
      bottom: isTop ? null : 90, // Moved up slightly to not cover the Play/Refresh buttons
      left: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: card.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: green, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 30, spreadRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: green, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(desc, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget actionButton(String text, IconData icon, VoidCallback? onTap,
      {bool isPrimary = false, bool isTutorialGlow = false, Key? key}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      key: key,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isTutorialGlow ? [BoxShadow(color: green.withOpacity(0.8), blurRadius: 25, spreadRadius: 6)] : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 20,
        ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          backgroundColor: isPrimary ? green : card,
          foregroundColor: isPrimary ? bg : Colors.white,
          disabledBackgroundColor: isPrimary ? green.withOpacity(0.3) : card.withOpacity(0.5),
          disabledForegroundColor: isPrimary ? bg.withOpacity(0.5) : Colors.white54,
          elevation: isPrimary && onTap != null ? 8 : 0,
          shadowColor: green.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
      ),
    );
  }
}
