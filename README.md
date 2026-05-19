# Life Lab - Conway's Game of Life

<p align="center">
  <img src="lib/assets/gif_readme.gif" alt="Life Lab Demo" width="600" />
</p>

**Life Lab** is a premium, highly interactive implementation of Conway's Game of Life built with Flutter. It combines the fascinating mathematical beauty of cellular automata with a modern, glassmorphic design and a robust professional test suite.

## 🧬 Features

- **Interactive Life Lab**: Tap or pan on the grid to bring cells to life. Watch patterns emerge and evolve in real-time.
- **Dynamic Rule System**: Don't just play by the standard rules. Use the "Rule Lab" to adjust the neighbors required for birth and survival to discover entirely new universes.
- **Educational Suite**: 
  - **Learn Screen**: Explore the history and mechanics of the game through a detailed FAQ and guide.
  - **Story Tutorial**: A guided, narrative onboarding experience for first-time users.
  - **Interactive Tutorial**: A step-by-step help guide to master the simulation controls.
- **Advanced State Detection**: The game detects when your colony has stabilized (Won), entered an endless loop (Oscillating), or completely vanished (Extinct).
- **Premium Aesthetics**: Designed with a sleek dark theme, neon green accents, smooth micro-animations, and glassmorphic UI elements.
- **Optimized Performance**: High-performance grid rendering optimized for 60fps, even during complex simulations.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.3.0)
- Dart SDK

### Installation
1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies.
3. Run `flutter run` on your preferred device.

## 🧪 Testing

Life Lab comes with a professional-grade, 100% deterministic test suite consisting of **147 tests** covering Unit, Integration, System, and Regression testing.

To run the full suite:
```bash
flutter test test/all_tests.dart
```

### Coverage Highlights:
- **Core Engine**: Mathematical verification of birth, survival, and neighbor counting.
- **UI & Navigation**: Tab switching, slider updates, and complex navigation flows.
- **End-to-End Simulation**: Accurate detection of stable states, endless loops, and total extinction.
- **Regression Guarding**: Verification of theme constants, double-tap guards, and proper timer/controller disposal to prevent memory leaks.

## 🛠️ Technical Details
- **UI Framework**: Flutter (Material 3)
- **State Management**: Optimized `setState` with local grid isolation for high-performance rendering.
- **Persistence**: `shared_preferences` for tracking user progress and onboarding status.
- **Testing Strategy**: Coordinate-based grid interaction and fixed-viewport testing for cross-platform consistency.

---
Built with 💚 by Randomwalk.ai
