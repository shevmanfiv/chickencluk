import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../../constants/assets.dart';
import '../cluck_rush_game.dart';

class Food extends SpriteComponent with HasGameReference<CluckRushGame> {
  final FoodConfig config;

  Food(this.config) : super(size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(config.assetFile);
    add(RectangleHitbox());
  }
  
  void collect() {
    removeFromParent();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Move left with game speed
    // Objects move at game speed relative to player
    position.x -= game.gameSpeed * dt;
    
    // Remove if off screen
    if (position.x < -width) {
      removeFromParent();
    }
  }
}
