import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import 'config/level_config.dart';
import 'components/player.dart';
import 'components/background.dart';
import 'components/object_manager.dart';
import 'components/food.dart';
import 'components/obstacle.dart';
import 'components/enemy.dart';
import 'components/lane_markers.dart';
import 'managers/audio_manager.dart';
import '../services/storage_service.dart';

/// Define lane Y positions (relative to screen height)
enum Lane { top, middle, bottom }

/// Main game class for Cluck Rush: The Egg Dash
/// 
/// This is the central game loop and manages all game components,
/// input handling, and game state.
class CluckRushGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  
  // Game state
  bool isPlaying = false;
  int score = 0;
  double _scoreAccumulator = 0.0; // Accumulate fractional score
  double fullness = 100.0;
  double gameSpeed = 300.0; // Pixels per second
  
  int level = 1;
  double decayRate = 5.0;         // Loses 5% per second
  double distanceTraveled = 0.0;  // Track progress
  double levelGoal = 1000.0;      // Distance to win (varies by level)

  // Stun/Hit handling
  bool _isStunned = false;
  bool get isStunned => _isStunned;
  double _preStunSpeed = 0.0;

  // Notifiers for UI
  final ValueNotifier<double> fullnessNotifier = ValueNotifier(100.0);
  final ValueNotifier<double> distanceNotifier = ValueNotifier(0.0);
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);

  late Player player;
  late ObjectManager objectManager;
  final AudioManager audioManager = AudioManager();

  // Lane Y coordinates (calculate based on viewport)
  // Keep lanes within the dirt road area (center band of screen)
  // 3 lanes only - tightly constrained
  double get laneTopY => size.y * 0.35;      // Top lane
  double get laneMiddleY => size.y * 0.50;   // Center lane
  double get laneBottomY => size.y * 0.65;   // Bottom lane

  double getLaneY(Lane lane) {
    switch (lane) {
      case Lane.top:
        return laneTopY;
      case Lane.middle:
        return laneMiddleY;
      case Lane.bottom:
        return laneBottomY;
    }
  }
  
  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue background
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Init Audio
    await audioManager.init();
    audioManager.playMenuMusic();

    // Add background
    add(Background());
    
    // Add lane markers (visual dividers between lanes)
    add(LaneMarkers());
    
    // Add player
    player = Player();
    add(player);

    // Add object manager
    objectManager = ObjectManager();
    add(objectManager);
    
    debugPrint('Cluck Rush Game loaded successfully!');
  }
  
  @override
  void update(double dt) {
    // Only update game components if playing
    if (isPlaying) {
      super.update(dt);
      
      // Game loop logic
      fullness -= decayRate * dt;
      distanceTraveled += gameSpeed * dt;
      
      // Accumulate fractional score and add whole points
      _scoreAccumulator += gameSpeed * dt * 0.1; // 10 points per 100 distance
      if (_scoreAccumulator >= 1.0) {
        final pointsToAdd = _scoreAccumulator.floor();
        score += pointsToAdd;
        _scoreAccumulator -= pointsToAdd;
      }
      
      // Update Notifiers
      fullnessNotifier.value = fullness;
      distanceNotifier.value = distanceTraveled;
      scoreNotifier.value = score;
      
      if (fullness <= 0) gameOver();
      if (distanceTraveled >= levelGoal) triggerVictory();
    }
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    // We pass the event to super even if not playing, 
    // but we only trigger game logic if playing
    // (though tap handling in menus is usually done via Flutter widgets overlay)
    super.onTapDown(event);
    
    if (isPlaying && !_isStunned) {
      player.jump();
      audioManager.playJump();
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isPlaying || _isStunned) return;

    final velocity = event.velocity.y;
    if (velocity < -100) {
      // Swipe Up
      player.moveLane(-1); 
      audioManager.playCluck();
    } else if (velocity > 100) {
      // Swipe Down
      player.moveLane(1);
      audioManager.playCluck();
    }
  }
  
  /// Start or restart the game
  void startGame({int levelNumber = 1}) {
    level = levelNumber;
    final config = LevelConfig.forLevel(level);

    isPlaying = true;
    _isStunned = false;
    score = 0;
    _scoreAccumulator = 0.0;
    fullness = 100.0;
    distanceTraveled = 0.0;
    
    gameSpeed = config.speed;
    levelGoal = config.goalDistance;
    decayRate = config.decayRate;

    // Reset Notifiers
    fullnessNotifier.value = fullness;
    distanceNotifier.value = distanceTraveled;
    scoreNotifier.value = score;
    levelNotifier.value = level;
    
    // Clear existing objects
    children.whereType<Food>().forEach((e) => e.removeFromParent());
    children.whereType<Obstacle>().forEach((e) => e.removeFromParent());
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    
    // Reset components
    player.reset();
    objectManager.reset(config);

    audioManager.playGameMusic();
    overlays.remove('MainMenu');
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('Victory');
    overlays.add('GameHud');
    
    debugPrint('Game started! Level: $level');
  }
  
  /// Pause the game
  void pauseGame() {
    isPlaying = false;
    audioManager.stopMusic();
    debugPrint('Game paused');
  }
  
  /// Resume the game
  void resumeGame() {
    isPlaying = true;
    audioManager.playGameMusic();
    overlays.remove('PauseMenu');
    overlays.add('GameHud');
  }

  /// Go to Main Menu
  void goToMainMenu() {
    isPlaying = false;
    audioManager.playMenuMusic();
    overlays.remove('GameHud');
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('Victory');
    overlays.add('MainMenu');
    
    // Clean up
    children.whereType<Food>().forEach((e) => e.removeFromParent());
    children.whereType<Obstacle>().forEach((e) => e.removeFromParent());
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    player.reset();
  }
  
  /// End the game and show game over screen
  void gameOver() {
    if (!isPlaying) return;
    isPlaying = false;
    audioManager.stopMusic();
    audioManager.playHit(); // Play hit/loss sound
    overlays.remove('GameHud');
    overlays.add('GameOver');
    debugPrint('Game Over! Final score: $score, Distance: ${distanceTraveled.toInt()}');
  }

  /// Trigger victory when level goal is reached
  void triggerVictory() {
    if (!isPlaying) return;
    isPlaying = false;
    audioManager.stopMusic();
    audioManager.playVictory();
    
    // Save progress to storage
    StorageService.instance.recordLevelCompletion(
      level: level,
      fullnessPercent: fullness,
    );
    
    overlays.remove('GameHud');
    overlays.add('Victory');
    debugPrint('Victory! Level $level completed. Final score: $score');
  }
  
  /// Add points to the score
  void addScore(int points) {
    score += points;
    scoreNotifier.value = score;
    debugPrint('Score: $score');
  }

  void addFullness(double amount, {Vector2? position}) {
    fullness = (fullness + amount).clamp(0.0, 100.0);
    fullnessNotifier.value = fullness;
    audioManager.playEat();
    
    if (position != null) {
      spawnEatEffect(position);
    }
  }

  void hitObstacle(double fullnessPenalty, double stunDuration) {
    if (_isStunned) return; // Already stunned

    reduceFullness(fullnessPenalty);
    
    // Apply Stun (Stop movement)
    if (stunDuration > 0) {
      _isStunned = true;
      _preStunSpeed = gameSpeed;
      gameSpeed = 0; // Stop scrolling

      // Timer to restore speed
      add(TimerComponent(
        period: stunDuration,
        removeOnFinish: true,
        onTick: () {
          if (isPlaying) { // Only restore if still playing
            gameSpeed = _preStunSpeed;
            _isStunned = false;
          }
        },
      ));
    }
  }

  void reduceFullness(double amount) {
    fullness = (fullness - amount).clamp(0.0, 100.0);
    fullnessNotifier.value = fullness;
    audioManager.playHit();
    
    // Screen Shake
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(5, 5),
        EffectController(
          duration: 0.05,
          alternate: true,
          repeatCount: 4,
        ),
      ),
    );

    if (fullness <= 0) {
      gameOver();
    }
  }
  
  void spawnEatEffect(Vector2 position) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 5,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2.random(Random())
              ..multiply(Vector2(100, 100)) // Scale speed
              ..sub(Vector2(50, 150)), // Upward bias
            position: position,
            child: CircleParticle(
              radius: 4,
              paint: Paint()..color = const Color(0xFFFFD54F), // Penny Yellow
            ),
          ),
        ),
      ),
    );
  }
}
