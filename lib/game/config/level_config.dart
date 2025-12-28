import 'dart:math';

/// Configuration for game levels
class LevelConfig {
  final int levelNumber;
  final int lanes;           // 2 for early levels, 3 for later
  final double speed;        // Base speed + (level * 10)
  final double spawnRate;    // Decreases each level (spawn interval)
  final double goalDistance;
  final double decayRate;    // Fullness decay per second
  final bool hasFoxes;       // Unlocked at level 4
  final bool hasMudPuddles;  // Unlocked at level 7
  
  const LevelConfig({
    required this.levelNumber,
    required this.lanes,
    required this.speed,
    required this.spawnRate,
    required this.goalDistance,
    required this.decayRate,
    required this.hasFoxes,
    required this.hasMudPuddles,
  });

  static LevelConfig forLevel(int level) {
    return LevelConfig(
      levelNumber: level,
      lanes: level < 4 ? 2 : 3,
      speed: 100.0 + (level * 10),
      spawnRate: max(0.5, 1.5 - (level * 0.1)),
      goalDistance: 3000.0 + (level * 500.0),
      decayRate: 4.0 + (level * 0.5), // Starts at 4.5%, increases 0.5% per level
      hasFoxes: level >= 4,
      hasMudPuddles: level >= 7,
    );
  }
}

