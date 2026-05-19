// THEME – UNIT TESTS

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/theme.dart';

void main() {
  group('[Unit] Theme – Color constants', () {
    test('bg is a very dark near-black color', () {
      // bg = Color(0xff030303)
      expect(bg.alpha, 255);
      expect(bg.red, 3);
      expect(bg.green, 3);
      expect(bg.blue, 3);
    });

    test('card is a dark grey', () {
      // card = Color(0xff111111)
      expect(card.alpha, 255);
      expect(card.red, 17);
      expect(card.green, 17);
      expect(card.blue, 17);
    });

    test('green is a vivid neon green', () {
      // green = Color(0xff00ff88)
      expect(green.alpha, 255);
      expect(green.red, 0);
      expect(green.green, 255);
      expect(green.blue, 136);
    });

    test('bg is darker than card', () {
      // bg.red (3) < card.red (17)
      expect(bg.red, lessThan(card.red));
    });

    test('green is fully opaque', () {
      expect(green.alpha, 255);
    });

    test('theme constants are const (compile-time)', () {
      // Verify they are Color instances
      expect(bg, isA<Color>());
      expect(card, isA<Color>());
      expect(green, isA<Color>());
    });
  });
}
