import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../constants/assets.dart';
import '../cluck_rush_game.dart';
import 'food.dart';
import 'obstacle.dart';
import 'enemy.dart';

class Player extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameReference<CluckRushGame>, CollisionCallbacks, TapCallbacks, DragCallbacks {
  
  Lane currentLane = Lane.middle;
  bool isInvincible = false;
  double _dragAccumulator = 0.0;
  static const double _dragThreshold = 30.0;
  
  Player() : super(size: Vector2(64, 64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Load sprites (all chicken images are single-frame sprites, not sprite sheets)
    final runSprite = await game.loadSprite(Assets.chickenRunFile);
    final jumpSprite = await game.loadSprite(Assets.chickenJumpFile);
    final hitSprite = await game.loadSprite(Assets.chickenDizzyFile);
    final idleSprite = await game.loadSprite(Assets.chickenIdleFile);

    // Create single-frame animations from each sprite
    final runAnimation = SpriteAnimation.spriteList([runSprite], stepTime: 0.1);
    final jumpAnimation = SpriteAnimation.spriteList([jumpSprite], stepTime: 0.1);
    final hitAnimation = SpriteAnimation.spriteList([hitSprite], stepTime: 0.1);
    final idleAnimation = SpriteAnimation.spriteList([idleSprite], stepTime: 0.1);

    animations = {
      PlayerState.running: runAnimation,
      PlayerState.jumping: jumpAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.idle: idleAnimation,
    };

    current = PlayerState.idle;
    
    // Set initial position
    position = Vector2(game.size.x * 0.2, game.getLaneY(currentLane));
    
    add(RectangleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Food) {
      game.addFullness(other.config.fullnessValue, position: other.position);
      other.collect();
    } else if (other is Obstacle) {
      // Use hitObstacle to apply stun + damage
      game.hitObstacle(other.config.fullnessPenalty, other.config.stunDuration);
      hit();
    } else if (other is Enemy) {
      // Enemies have pushback + damage
      game.reduceFullness(other.config.fullnessPenalty);
      hit();
      pushback(other.config.pushbackDistance);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Consume the event so the game doesn't register a jump when clicking the chicken
    event.handled = true;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragAccumulator = 0.0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!game.isPlaying || game.isStunned) return;

    // Accumulate drag distance in Y axis
    _dragAccumulator += event.localDelta.y;

    // Check threshold for immediate lane switch during drag
    if (_dragAccumulator.abs() > _dragThreshold) {
      if (_dragAccumulator < 0) {
        // Drag Up
        if (currentLane.index > 0) { // Only move if not in top lane
          moveLane(-1);
          game.audioManager.playCluck();
          _dragAccumulator = 0.0; // Reset after move
        } else {
          // If we can't move, just consume the drag to prevent "stuck" feeling
          _dragAccumulator = 0.0;
        }
      } else {
        // Drag Down
        if (currentLane.index < 2) { // Only move if not in bottom lane
          moveLane(1);
          game.audioManager.playCluck();
          _dragAccumulator = 0.0; // Reset after move
        } else {
           // If we can't move, just consume the drag
           _dragAccumulator = 0.0;
        }
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!game.isPlaying || game.isStunned) return;

    // If drag wasn't enough to trigger update, check velocity (swipe)
    final velocity = event.velocity.y;
    if (velocity < -100 && currentLane.index > 0) {
      // Swipe Up
      moveLane(-1);
      game.audioManager.playCluck();
    } else if (velocity > 100 && currentLane.index < 2) {
      // Swipe Down
      moveLane(1);
      game.audioManager.playCluck();
    }
    
    _dragAccumulator = 0.0;
    
    // Consume drag so it doesn't propagate if we handled it
    event.handled = true;
  }

  void pushback(double distance) {
    // Move back
    add(MoveEffect.by(
      Vector2(-distance, 0),
      EffectController(duration: 0.2, curve: Curves.easeOut),
      onComplete: () {
        // Recover to original position slowly
        add(MoveEffect.to(
          Vector2(game.size.x * 0.2, game.getLaneY(currentLane)),
          EffectController(duration: 1.0, curve: Curves.linear),
        ));
      },
    ));
  }

  void moveLane(int direction) {
    // direction: -1 (up/top), 1 (down/bottom)
    int newLaneIndex = currentLane.index + direction;
    
    // Clamp to valid lanes
    if (newLaneIndex < 0) newLaneIndex = 0;
    if (newLaneIndex > 2) newLaneIndex = 2;

    if (newLaneIndex != currentLane.index) {
      currentLane = Lane.values[newLaneIndex];
      final targetY = game.getLaneY(currentLane);
      
      add(MoveEffect.to(
        Vector2(position.x, targetY),
        EffectController(duration: 0.2, curve: Curves.easeOut),
      ));
    }
  }

  void jump() {
    if (current == PlayerState.jumping) return;
    
    final originalState = current;
    current = PlayerState.jumping;
    
    // Jump Stretch (Takeoff)
    add(ScaleEffect.by(
      Vector2(0.8, 1.2),
      EffectController(duration: 0.1, reverseDuration: 0.1),
    ));
    
    add(MoveEffect.by(
      Vector2(0, -80), // Jump height
      EffectController(
        duration: 0.5,
        alternate: true,
        curve: Curves.easeOut,
      ),
      onComplete: () {
        if (current == PlayerState.jumping) {
          current = originalState == PlayerState.idle ? PlayerState.idle : PlayerState.running;
          
          // Land Squash (Landing)
          add(ScaleEffect.by(
            Vector2(1.2, 0.8),
            EffectController(duration: 0.1, reverseDuration: 0.1),
          ));
        }
      },
    ));
  }
  
  void hit() {
    if (isInvincible) return; // Ignore hits during invincibility
    
    current = PlayerState.hit;
    isInvincible = true;
    
    // Brief invincibility frames (1 second)
    add(TimerComponent(
      period: 1.0, 
      removeOnFinish: true,
      onTick: () {
        current = PlayerState.running;
        isInvincible = false;
      },
    ));
    
    // Flashing effect
    add(OpacityEffect.to(
      0.2,
      EffectController(
        duration: 0.1,
        reverseDuration: 0.1,
        repeatCount: 5,
      ),
    ));
  }

  void reset() {
    currentLane = Lane.middle;
    position = Vector2(game.size.x * 0.2, game.getLaneY(currentLane));
    current = PlayerState.running;
    isInvincible = false;
    opacity = 1.0;
    children.whereType<Effect>().forEach((e) => e.removeFromParent());
    children.whereType<TimerComponent>().forEach((e) => e.removeFromParent());
  }
}
