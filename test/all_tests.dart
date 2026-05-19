// MASTER TEST RUNNER
// Run with: flutter test test/all_tests.dart

import 'play_screen/unit_test.dart'        as play_unit;
import 'play_screen/integration_test.dart' as play_integration;
import 'play_screen/system_test.dart'      as play_system;
import 'play_screen/regression_test.dart'  as play_regression;

import 'home_screen/unit_test.dart'        as home_unit;
import 'home_screen/integration_test.dart' as home_integration;
import 'home_screen/system_test.dart'      as home_system;
import 'home_screen/regression_test.dart'  as home_regression;

import 'learn_screen/unit_test.dart'        as learn_unit;
import 'learn_screen/integration_test.dart' as learn_integration;
import 'learn_screen/system_test.dart'      as learn_system;
import 'learn_screen/regression_test.dart'  as learn_regression;

import 'rules_screen/unit_test.dart'        as rules_unit;
import 'rules_screen/integration_test.dart' as rules_integration;
import 'rules_screen/system_test.dart'      as rules_system;
import 'rules_screen/regression_test.dart'  as rules_regression;

import 'welcome_screen/unit_test.dart'        as welcome_unit;
import 'welcome_screen/integration_test.dart' as welcome_integration;
import 'welcome_screen/system_test.dart'      as welcome_system;
import 'welcome_screen/regression_test.dart'  as welcome_regression;

import 'tutorial_screen/unit_test.dart'        as tutorial_unit;
import 'tutorial_screen/integration_test.dart' as tutorial_integration;
import 'tutorial_screen/system_test.dart'      as tutorial_system;
import 'tutorial_screen/regression_test.dart'  as tutorial_regression;

import 'story_tutorial_screen/unit_test.dart'        as story_unit;
import 'story_tutorial_screen/integration_test.dart' as story_integration;
import 'story_tutorial_screen/system_test.dart'      as story_system;
import 'story_tutorial_screen/regression_test.dart'  as story_regression;

import 'main/unit_test.dart'        as main_unit;
import 'main/integration_test.dart' as main_integration;

import 'theme/unit_test.dart'        as theme_unit;
import 'theme/integration_test.dart' as theme_integration;
import 'theme/system_test.dart'      as theme_system;
import 'theme/regression_test.dart'  as theme_regression;

void main() {
  // ── Play Screen ──────────────────────────────────────────────────────────
  play_unit.main();
  play_integration.main();
  play_system.main();
  play_regression.main();

  // ── Home Screen ──────────────────────────────────────────────────────────
  home_unit.main();
  home_integration.main();
  home_system.main();
  home_regression.main();

  // ── Learn Screen ─────────────────────────────────────────────────────────
  learn_unit.main();
  learn_integration.main();
  learn_system.main();
  learn_regression.main();

  // ── Rules Screen ─────────────────────────────────────────────────────────
  rules_unit.main();
  rules_integration.main();
  rules_system.main();
  rules_regression.main();

  // ── Welcome Screen ───────────────────────────────────────────────────────
  welcome_unit.main();
  welcome_integration.main();
  welcome_system.main();
  welcome_regression.main();

  // ── Tutorial Screen (Help) ────────────────────────────────────────────────
  tutorial_unit.main();
  tutorial_integration.main();
  tutorial_system.main();
  tutorial_regression.main();

  // ── Story Tutorial Screen (First Time) ────────────────────────────────────
  story_unit.main();
  story_integration.main();
  story_system.main();
  story_regression.main();

  // ── Main App ─────────────────────────────────────────────────────────────
  main_unit.main();
  main_integration.main();

  // ── Theme ────────────────────────────────────────────────────────────────
  theme_unit.main();
  theme_integration.main();
  theme_system.main();
  theme_regression.main();
}
