import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'home_screen.dart';

class StoryTutorialScreen extends StatefulWidget {
  const StoryTutorialScreen({super.key});

  @override
  State<StoryTutorialScreen> createState() => _StoryTutorialScreenState();
}

class _StoryTutorialScreenState extends State<StoryTutorialScreen> with SingleTickerProviderStateMixin {
  final int size = 10;
  int step = 1;
  String title = "";
  String subtitle = "";
  
  Set<int> targets = {};
  Set<int> filled = {};
  Map<int, Color> overrides = {};
  bool allowTap = false;
  bool _showNextButton = false;
  late AnimationController _swipeController;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _startNeighborsSequence();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialTab: 0)),
    );
  }

  void _onCellTap(int index) {
    if (!allowTap || !targets.contains(index)) return;
    if (filled.contains(index)) return;
    
    setState(() {
      filled.add(index);
    });

    if (filled.length == targets.length) {
      allowTap = false;
      if (step == 1) _playNeighborsAnimation();
      else if (step == 2) _playDeathAnimation();
      else if (step == 3) _playSurvivalAnimation();
      else if (step == 4) _playOverpopAnimation();
      else if (step == 5) _playBirthAnimation();
      else if (step == 6) _playWinLoseAnimation();
    }
  }

  void _startSequence(int s) {
    if (s == 1) _startNeighborsSequence();
    else if (s == 2) _startDeathSequence();
    else if (s == 3) _startSurvivalSequence();
    else if (s == 4) _startOverpopSequence();
    else if (s == 5) _startBirthSequence();
    else if (s == 6) _startWinLoseSequence();
  }

  void _onNextPressed() {
    if (!_showNextButton) return;
    if (step == 6) {
      _finish();
      return;
    }
    setState(() {
      _showNextButton = false;
    });
    _startSequence(step + 1);
  }

  void _onBackPressed() {
    if (step > 1) {
      setState(() {
        _showNextButton = false;
      });
      _startSequence(step - 1);
    }
  }

  // --- STEP 1: NEIGHBORS ---
  void _startNeighborsSequence() {
    setState(() {
      step = 1;
      title = "The Grid";
      subtitle = "Tap the glowing center cell to begin.";
      targets = {45};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playNeighborsAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Every cell has 8 neighbors. They determine if a cell lives or dies.");
    
    // Highlight neighbors
    for (int i = 0; i < 2; i++) {
      setState(() {
        for (int n in [34, 35, 36, 44, 46, 54, 55, 56]) {
          overrides[n] = Colors.blueAccent.withOpacity(0.4);
        }
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => overrides.clear());
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
    }
    setState(() => _showNextButton = true);
  }

  // --- STEP 2: DEATH ---
  void _startDeathSequence() {
    setState(() {
      step = 2;
      title = "Rule 1: Isolation";
      subtitle = "Draw a single isolated cell anywhere.";
      targets = {}; // Allow any cell
      for(int i=0; i<100; i++) targets.add(i);
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playDeathAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "A cell with fewer than 2 neighbors dies from loneliness.");
    
    int cell = filled.first;
    for (int i = 0; i < 2; i++) {
      setState(() => overrides[cell] = Colors.redAccent);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => overrides[cell] = green);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }
    setState(() { filled.clear(); overrides.clear(); });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 3: SURVIVAL ---
  void _startSurvivalSequence() {
    setState(() {
      step = 3;
      title = "Rule 2: Balance";
      subtitle = "Tap 4 cells to form a 2x2 square.";
      targets = {44, 45, 54, 55};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playSurvivalAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Cells with 2 or 3 neighbors stay alive. This is a stable 'Still Life'.");
    
    for (int i = 0; i < 2; i++) {
      setState(() {
        for (int n in [44, 45, 54, 55]) overrides[n] = Colors.blueAccent;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => overrides.clear());
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
    }
    setState(() => _showNextButton = true);
  }

  // --- STEP 4: OVERPOPULATION ---
  void _startOverpopSequence() {
    setState(() {
      step = 4;
      title = "Rule 3: Crowding";
      subtitle = "Tap 5 cells to form a plus (+) shape.";
      targets = {34, 43, 44, 45, 54};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playOverpopAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "Too crowded! The center cell has 4 neighbors and perishes.");

    for (int i = 0; i < 2; i++) {
      setState(() => overrides[44] = Colors.redAccent);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => overrides[44] = green);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }
    setState(() { filled.remove(44); overrides.clear(); });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 5: BIRTH ---
  void _startBirthSequence() {
    setState(() {
      step = 5;
      title = "Rule 4: Reproduction";
      subtitle = "Tap 3 cells to form an 'L' shape.";
      targets = {44, 45, 54};
      filled.clear();
      allowTap = true;
    });
  }

  Future<void> _playBirthAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => subtitle = "An empty space with exactly 3 neighbors brings a new cell to life!");
    
    for (int i = 0; i < 2; i++) {
      setState(() => overrides[55] = green.withOpacity(0.5));
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => overrides.clear());
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }
    setState(() => filled.add(55));
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  // --- STEP 6: WIN/LOSE ---
  void _startWinLoseSequence() {
    setState(() {
      step = 6;
      title = "Goal";
      subtitle = "Find stable patterns or infinite loops to win.";
      targets = {};
      filled.clear();
      allowTap = false;
    });
    _playWinLoseAnimation();
  }

  Future<void> _playWinLoseAnimation() async {
    // Show a blinker pattern
    for (int i = 0; i < 3; i++) {
      setState(() {
        filled.clear();
        filled.addAll({44, 45, 46});
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        filled.clear();
        filled.addAll({35, 45, 55});
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    setState(() {
      filled.clear();
      subtitle = "But if all cells die, you LOSE.";
    });
    
    for (int i = 0; i < 2; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        for (int j = 0; j < 100; j++) overrides[j] = Colors.redAccent.withOpacity(0.1);
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => overrides.clear());
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showNextButton = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text("SKIP", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onPanUpdate: (details) {
                            if (!allowTap) return;
                            double cellWidth = 300 / size;
                            int col = (details.localPosition.dx / cellWidth).floor();
                            int row = (details.localPosition.dy / cellWidth).floor();
                            if (row >= 0 && row < size && col >= 0 && col < size) {
                              _onCellTap(row * size + col);
                            }
                          },
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: size),
                            itemCount: size * size,
                            itemBuilder: (context, index) {
                              bool isTarget = targets.contains(index);
                              bool isFilled = filled.contains(index);
                              Color cellColor = overrides[index] ?? (isFilled ? green : (isTarget ? green.withOpacity(0.2) : Colors.white.withOpacity(0.05)));
                              return GestureDetector(
                                onTap: () => _onCellTap(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                ),
                              );
                            },
                          ),

                        ),
                        if (allowTap)
                          IgnorePointer(
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 0.8).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeInOut)),
                              child: Icon(Icons.touch_app, size: 60, color: Colors.white.withOpacity(0.8)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Text(title, textAlign: TextAlign.center, style: const TextStyle(color: green, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (step > 1)
                      TextButton(onPressed: _onBackPressed, child: const Text("BACK", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)))
                    else
                      const SizedBox(width: 60),
                    if (_showNextButton)
                      ElevatedButton(
                        onPressed: _onNextPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          foregroundColor: bg,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(step == 6 ? "FINISH" : "NEXT", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
