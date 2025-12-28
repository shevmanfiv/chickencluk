import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../cluck_rush_game.dart';

/// Visual lane dividers to help players see the 3 lanes
class LaneMarkers extends PositionComponent with HasGameReference<CluckRushGame> {
  final List<_LaneDot> _dots = [];
  static const int dotCount = 8; // Number of dots across the screen
  static const double dotSpacing = 150.0; // Space between dots
  
  @override
  Future<void> onLoad() async {
    // Create dots for top lane divider (between top and middle)
    final topDividerY = (game.laneTopY + game.laneMiddleY) / 2;
    // Create dots for bottom lane divider (between middle and bottom)
    final bottomDividerY = (game.laneMiddleY + game.laneBottomY) / 2;
    
    for (int i = 0; i < dotCount; i++) {
      final xPos = i * dotSpacing;
      
      // Top divider dot
      final topDot = _LaneDot(position: Vector2(xPos, topDividerY));
      _dots.add(topDot);
      add(topDot);
      
      // Bottom divider dot
      final bottomDot = _LaneDot(position: Vector2(xPos, bottomDividerY));
      _dots.add(bottomDot);
      add(bottomDot);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!game.isPlaying) return;
    
    // Move all dots left with game speed
    for (final dot in _dots) {
      dot.position.x -= game.gameSpeed * dt;
      
      // Wrap around when off-screen
      if (dot.position.x < -20) {
        dot.position.x += dotCount * dotSpacing;
      }
    }
  }
}

class _LaneDot extends CircleComponent {
  _LaneDot({required Vector2 position}) 
      : super(
          radius: 4,
          position: position,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0x40FFFFFF) // Semi-transparent white
            ..style = PaintingStyle.fill,
        );
}

