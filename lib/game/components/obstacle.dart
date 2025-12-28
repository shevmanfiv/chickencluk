import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../constants/assets.dart';
import '../cluck_rush_game.dart';

class Obstacle extends SpriteComponent with HasGameReference<CluckRushGame> {
  final ObstacleConfig config;

  Obstacle(this.config) : super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(config.assetFile);
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Move left with game speed
    position.x -= game.gameSpeed * dt;
    
    // Remove if off screen
    if (position.x < -width) {
      removeFromParent();
    }
  }
}
