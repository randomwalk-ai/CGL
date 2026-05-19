// THEME – REGRESSION TESTS
// Guards against accidental colour constant changes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_lab/theme.dart';

void main() {
  group('[Regression] Theme – Constant value guard', () {
    test('bg value is exactly 0xff030303', () {
      expect(bg.value, 0xff030303);
    });

    test('card value is exactly 0xff111111', () {
      expect(card.value, 0xff111111);
    });

    test('green value is exactly 0xff00ff88', () {
      expect(green.value, 0xff00ff88);
    });

    test('withOpacity(0) on green has zero alpha', () {
      expect(green.withOpacity(0).alpha, 0);
    });

    test('withOpacity(1) on bg has full alpha', () {
      expect(bg.withOpacity(1.0).alpha, 255);
    });
  });
}
