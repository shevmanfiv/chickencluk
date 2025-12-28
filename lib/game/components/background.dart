import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../../constants/assets.dart';
import '../cluck_rush_game.dart';

class Background extends ParallaxComponent<CluckRushGame> {
  @override
  Future<void> onLoad() async {
    final layers = await Future.wait(
      Assets.parallaxLayers.asMap().entries.map((entry) async {
        final index = entry.key;
        final filename = entry.value;
        // Use the defined speed multipliers from Assets
        final speedMultiplier = Assets.parallaxSpeeds[index];
        
        return ParallaxLayer(
          await game.loadParallaxImage(
            filename,
            fill: LayerFill.height, // Ensure it fills screen height
          ),
          velocityMultiplier: Vector2(speedMultiplier, 0),
        );
      }),
    );

    parallax = Parallax(
      layers,
      baseVelocity: Vector2(game.gameSpeed, 0), 
    );
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    // Update base velocity if game speed changes (e.g. speeds up over time)
    parallax?.baseVelocity = Vector2(game.gameSpeed, 0);
  }
}

