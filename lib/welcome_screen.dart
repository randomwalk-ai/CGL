import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import 'home_screen.dart';
import 'story_tutorial_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController glow;
  late Timer bgTimer;
  bool _isEntering = false;
  bool _isFirstTime = true;

  final int bgRows = 40;
  final int bgCols = 15;
  late List<List<int>> bgGrid;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();

    glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    final random = Random();
    bgGrid = List.generate(
      bgRows,
      (_) => List.generate(bgCols, (_) => random.nextDouble() < 0.25 ? 1 : 0),
    );

    bgTimer = Timer.periodic(const Duration(milliseconds: 600), (_) async {
      if (!mounted) return;
      // Send the heavy calculation to a background worker
      final newGrid = await compute(_calculateNextGenInIsolate, bgGrid);
      if (mounted) {
        setState(() {
          bgGrid = newGrid;
        });
      }
    });
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  @override
  void dispose() {
    bgTimer.cancel();
    glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedScale(
              scale: _isEntering ? 12.0 : 1.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInExpo,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.2,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: bgCols,
                    ),
                    itemCount: bgRows * bgCols,
                    itemBuilder: (context, index) {
                      int r = index ~/ bgCols;
                      int c = index % bgCols;
                      bool alive = bgGrid[r][c] == 1;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: alive ? green : Colors.transparent,
                          border: Border.all(
                            color: alive ? green : green.withOpacity(0.2),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: alive
                              ? [
                                  BoxShadow(
                                    color: green.withOpacity(0.5),
                                    blurRadius: 5,
                                  )
                                ]
                              : [],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _isEntering ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: glow,
                    builder: (_, __) {
                      return Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: green.withOpacity(.08),
                          boxShadow: [
                            BoxShadow(
                              color: green.withOpacity(.2 + glow.value * .3),
                              blurRadius: 20 + glow.value * 30,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: green,
                          size: 50,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "WELCOME TO",
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "CONWAY'S\nGAME OF LIFE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Touch • Create • Evolve",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      SizedBox(
                        width: 240,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isEntering) return;
                            setState(() {
                              _isEntering = true;
                            });
                            Future.delayed(const Duration(milliseconds: 1000), () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isFirstTime', false);
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 800),
                                  pageBuilder: (_, __, ___) => _isFirstTime ? const StoryTutorialScreen() : const HomeScreen(initialTab: 0),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: bg,
                            elevation: 10,
                            shadowColor: green.withOpacity(0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isFirstTime ? "START TUTORIAL" : "ENTER GRID",
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 240,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isFirstTime ? null : () {
                            if (_isEntering) return;
                            setState(() {
                              _isEntering = true;
                            });
                            // Let the background zoom in before transitioning
                            Future.delayed(const Duration(milliseconds: 1000), () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('isFirstTime', false);
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 800),
                                  pageBuilder: (_, __, ___) => const StoryTutorialScreen(),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isFirstTime ? Colors.white30 : green,
                            side: BorderSide(color: _isFirstTime ? Colors.white12 : green, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _isFirstTime ? "ENTER GRID" : "START TUTORIAL",
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              letterSpacing: 1.5,
                              color: _isFirstTime ? Colors.white30 : green
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Top-level function that runs in a background Isolate to prevent UI jank
List<List<int>> _calculateNextGenInIsolate(List<List<int>> currentGrid) {
  if (currentGrid.isEmpty) return currentGrid;
  int rows = currentGrid.length;
  int cols = currentGrid[0].length;
  List<List<int>> next = List.generate(rows, (_) => List.filled(cols, 0));
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      int neighbors = 0;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          int nr = r + dr;
          int nc = c + dc;
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
