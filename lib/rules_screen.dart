
// Force recompile
import 'package:flutter/material.dart';
import 'theme.dart';

class RulesScreen extends StatelessWidget {

  final int birthRule;
  final int surviveMin;
  final int surviveMax;

  final Function(int) onBirthChanged;
  final Function(int) onSurviveMinChanged;
  final Function(int) onSurviveMaxChanged;

  const RulesScreen({
    super.key,
    required this.birthRule,
    required this.surviveMin,
    required this.surviveMax,
    required this.onBirthChanged,
    required this.onSurviveMinChanged,
    required this.onSurviveMaxChanged,
  });

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: ListView(

        padding:
        const EdgeInsets.all(20),

        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "RULES LAB",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Experiment with life.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  onBirthChanged(3);
                  onSurviveMinChanged(2);
                  onSurviveMaxChanged(3);
                },
                icon: const Icon(Icons.restore, size: 16),
                label: const Text("Reset", style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: green,
                  side: const BorderSide(color: green, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          sliderCard(
            "BIRTH RULE",
            birthRule,
            onBirthChanged,
            "Standard: 3\nA dead cell needs exactly this many neighbors to come to life.",
          ),

          sliderCard(
            "SURVIVE (MIN)",
            surviveMin,
            onSurviveMinChanged,
            "Standard: 2\nA living cell needs at least this many neighbors to survive.",
          ),

          sliderCard(
            "SURVIVE (MAX)",
            surviveMax,
            onSurviveMaxChanged,
            "Standard: 3\nA living cell needs no more than this many neighbors to survive.",
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget sliderCard(
      String title,
      int value,
      Function(int) onChanged,
      String tooltipText) {

    return Container(

      margin:
      const EdgeInsets.only(
          bottom: 16),

      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(

        color: card,

        borderRadius:
        BorderRadius.circular(
            20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: Column(

        children: [

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: tooltipText,
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: const Duration(seconds: 4),
                    preferBelow: false,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: green.withOpacity(0.3)),
                    ),
                    textStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    child: const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  ),
                ],
              ),
              Text(
                value.toString(),
                style: const TextStyle(color: green, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Slider(

            activeColor:
            green,

            value:
            value.toDouble(),

            min: 1,
            max: 8,

            divisions: 7,

            onChanged:
                (v) {

              onChanged(
                  v.toInt());
            },
          )
        ],
      ),
    );
  }
}
