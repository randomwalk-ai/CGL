import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "ABOUT THE GAME",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: const Row(
              children: [
                _MiniDemo(frames: _glider, crossAxisCount: 5, size: 80),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    "Draw an initial pattern and watch it evolve!\n\nWin by finding a stable pattern or endless loop. Lose if all cells become empty.",
                    style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Text(
            "THE RULES",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _animatedRuleRow("SURVIVAL", "2 or 3 live neighbor cells", "The cell has perfect balance and stays a Live cell.", _survival, Icons.check_circle, green),
          _animatedRuleRow("BIRTH", "Exactly 3 live neighbor cells", "A Live cell is born in an Empty cell space.", _reproduction, Icons.check_circle, green),
          _animatedRuleRow("DEATH (Lonely)", "0 or 1 live neighbor cells", "The cell becomes an Empty cell from isolation.", _underpopulation, Icons.cancel, Colors.redAccent),
          _animatedRuleRow("DEATH (Crowded)", "> 3 live neighbor cells", "The cell becomes an Empty cell from overpopulation.", _overpopulation, Icons.cancel, Colors.redAccent),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          const Text(
            "FAQ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          faqItem("Is this a game you play?", "It's known as a 'zero-player game'. You set up the initial configuration and watch how it evolves based on the rules without further input!"),
          faqItem("Why is it called the 'Game of Life'?", "Created by mathematician John Conway in 1970, it perfectly simulates the life, death, and reproduction of biological cells using simple math."),
          faqItem("What are Gliders?", "Gliders are special patterns of cells that move across the grid infinitely. They 'fly' diagonally across the board. Try drawing a small asymmetrical shape and see if it moves!"),
          faqItem("Can I change the rules?", "Absolutely! Tap the 'Rule Lab' icon (the filter icon) at the top of the Play screen to experiment. Changing the required neighbors for birth or survival creates entirely new and bizarre universes."),
          const SizedBox(height: 40),
          Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                children: [
                  const TextSpan(text: "Built by "),
                  TextSpan(
                    text: "Randomwalk.ai",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri url = Uri.parse('https://randomwalk.ai/');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint('Could not launch $url');
                        }
                      },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _animatedRuleRow(String title, String condition, String desc, List<List<int>> frames, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _MiniDemo(frames: frames, crossAxisCount: 5, size: 70),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget faqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        shape: const Border(), // Removes the default ExpansionTile borders
        collapsedShape: const Border(),
        iconColor: green,
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),
          ),
        ],
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

const _glider = [
  [0,0,1,0,0, 1,0,1,0,0, 0,1,1,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,1,0,0,0, 0,1,1,0,0, 1,0,1,0,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,1,0,0, 0,0,1,0,0, 0,1,1,1,0, 0,0,0,0,0, 0,0,0,0,0],
  [0,0,0,0,0, 0,1,0,1,0, 0,0,1,1,0, 0,0,1,0,0, 0,0,0,0,0],
];
