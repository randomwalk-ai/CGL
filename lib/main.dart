import 'package:flutter/material.dart';

import 'theme.dart';
import 'welcome_screen.dart';

void main() {
  runApp(const LifeLab());
}

class LifeLab extends StatelessWidget {
  const LifeLab({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const WelcomeScreen(),
    );
  }
}
