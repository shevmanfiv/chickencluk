import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../constants/assets.dart';
import '../cluck_rush_game.dart';

class Enemy extends SpriteComponent with HasGameReference<CluckRushGame> {
  final EnemyConfig config;
  final double runSpeed = 150.0; // Fox runs towards player

  Enemy(this.config) : super(size: Vector2(60, 45), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(config.assetFile);
    add(RectangleHitbox());
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Move left (game speed + own speed)
    // This makes the fox approach faster than static objects
    position.x -= (game.gameSpeed + runSpeed) * dt;
    
    // Remove if off screen
    if (position.x < -width) {
      removeFromParent();
    }
  }
}
