import 'dart:math';
import 'package:flame/components.dart';
import '../../constants/assets.dart';
import '../config/level_config.dart';
import '../cluck_rush_game.dart';
import 'food.dart';
import 'obstacle.dart';
import 'enemy.dart';

class ObjectManager extends Component with HasGameReference<CluckRushGame> {
  final Random _rand = Random();
  late Timer _spawnTimer;
  LevelConfig? _currentConfig;
  
  // Spawn timer: starts at 1.5s, decreases by 0.1s per level
  double spawnInterval = 1.5;
  
  // Random lane selection
  Lane getRandomLane() => Lane.values[_rand.nextInt(3)];
  
  // Object pool for performance
  final List<PositionComponent> _objectPool = [];

  @override
  Future<void> onLoad() async {
    // Initial timer setup
    _spawnTimer = Timer(spawnInterval, repeat: true, onTick: _spawnObject);
    _spawnTimer.start();
  }

  @override
  void update(double dt) {
    if (game.isPlaying) {
      _spawnTimer.update(dt);
    }
  }

  void _spawnObject() {
    final lane = getRandomLane();
    final yPos = game.getLaneY(lane);
    final xPos = game.size.x + 100; // Start off-screen right

    // Randomly select type
    // 50% Food, 40% Obstacle, 10% Enemy (if unlocked)
    final typeVal = _rand.nextDouble();
    PositionComponent obj;
    
    // Check unlocks
    final bool canSpawnFox = _currentConfig?.hasFoxes ?? false;
    final bool canSpawnMud = _currentConfig?.hasMudPuddles ?? false;

    if (typeVal < 0.5) {
      // Food
      final foodType = FoodConfig.all[_rand.nextInt(FoodConfig.all.length)];
      obj = Food(foodType);
    } else if (typeVal < 0.9 || !canSpawnFox) {
      // Obstacle
      List<ObstacleConfig> availableObstacles = ObstacleConfig.basic;
      if (canSpawnMud) {
        availableObstacles = ObstacleConfig.all;
      }
      
      final obsType = availableObstacles[_rand.nextInt(availableObstacles.length)];
      obj = Obstacle(obsType);
    } else {
      // Enemy (only if unlocked and rolled > 0.9)
      obj = Enemy(EnemyConfig.fox);
    }

    obj.position = Vector2(xPos, yPos);
    game.add(obj);
    
    // Add to pool for tracking
    _objectPool.add(obj);
  }

  void reset(LevelConfig config) {
    _currentConfig = config;
    spawnInterval = config.spawnRate;
    _spawnTimer.limit = spawnInterval;
    _spawnTimer.reset();
    _spawnTimer.start();
    _objectPool.clear();
  }
}
