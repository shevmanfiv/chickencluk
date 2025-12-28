/// Cluck Rush - Asset Path Constants
///
/// Centralized asset paths for easy reference and refactoring.
/// All paths are relative to the assets/ folder.
class Assets {
  Assets._(); // Private constructor to prevent instantiation

  // ============================================
  // IMAGE ASSETS
  // ============================================
  
  static const String _imagesPath = 'assets/images/';
  
  // Player (Chicken) Sprites
  static const String chickenRun = '${_imagesPath}chicken_run.png';
  static const String chickenJump = '${_imagesPath}chicken_jump.png';
  static const String chickenDizzy = '${_imagesPath}chicken_dizzy.png';
  static const String chickenIdle = '${_imagesPath}chicken_idle.png';
  
  // Food Items
  static const String foodCorn = '${_imagesPath}food_corn.png';
  static const String foodWorm = '${_imagesPath}food_worm.png';
  
  // Obstacles
  static const String obstacleHayBale = '${_imagesPath}obstacle_hay_bale.png';
  static const String obstacleRock = '${_imagesPath}obstacle_rock.png';
  static const String obstacleMudPuddle = '${_imagesPath}obstacle_mud_puddle.png';
  
  // Enemies
  static const String enemyFox = '${_imagesPath}enemy_fox.png';
  
  // Collectibles
  static const String collectibleEgg = '${_imagesPath}collectible_egg.png';
  
  // Background / Parallax Layers
  static const String backgroundSky = '${_imagesPath}background_sky.png';
  static const String backgroundHills = '${_imagesPath}background_hills.png';
  static const String backgroundGround = '${_imagesPath}background_ground.png';
  static const String backgroundFence = '${_imagesPath}background_fence.png';
  
  // UI Elements
  static const String uiButtonPlay = '${_imagesPath}ui_button_play.png';
  static const String uiButtonPause = '${_imagesPath}ui_button_pause.png';
  static const String uiButtonHome = '${_imagesPath}ui_button_home.png';
  static const String uiProgressBarFrame = '${_imagesPath}ui_progress_bar_frame.png';

  // ============================================
  // AUDIO ASSETS
  // ============================================
  
  static const String _audioPath = 'assets/audio/';
  
  // Background Music
  static const String musicMainMenu = '${_audioPath}mainmenuSong.mp3';
  static const String musicGameplay = '${_audioPath}playSong.mp3';
  
  // Sound Effects
  static const String sfxCluck = '${_audioPath}chickenCluck.mp3';
  static const String sfxEating = '${_audioPath}eating.mp3';
  static const String sfxJump = '${_audioPath}Jump.mp3';
  static const String sfxHit = '${_audioPath}wrongmove.mp3';
  static const String sfxVictory = '${_audioPath}winLayegg.mp3';

  // ============================================
  // AUDIO FILENAMES (for Flame Audio)
  // Flame Audio expects just the filename, not full path
  // ============================================
  
  static const String musicMainMenuFile = 'mainmenuSong.mp3';
  static const String musicGameplayFile = 'playSong.mp3';
  static const String sfxCluckFile = 'chickenCluck.mp3';
  static const String sfxEatingFile = 'eating.mp3';
  static const String sfxJumpFile = 'Jump.mp3';
  static const String sfxHitFile = 'wrongmove.mp3';
  static const String sfxVictoryFile = 'winLayegg.mp3';

  // ============================================
  // IMAGE FILENAMES (for Flame image loading)
  // Flame expects just the filename, not full path
  // ============================================
  
  // Player sprites
  static const String chickenRunFile = 'chicken_run.png';
  static const String chickenJumpFile = 'chicken_jump.png';
  static const String chickenDizzyFile = 'chicken_dizzy.png';
  static const String chickenIdleFile = 'chicken_idle.png';
  
  // Food
  static const String foodCornFile = 'food_corn.png';
  static const String foodWormFile = 'food_worm.png';
  
  // Obstacles
  static const String obstacleHayBaleFile = 'obstacle_hay_bale.png';
  static const String obstacleRockFile = 'obstacle_rock.png';
  static const String obstacleMudPuddleFile = 'obstacle_mud_puddle.png';
  
  // Enemy
  static const String enemyFoxFile = 'enemy_fox.png';
  
  // Collectibles
  static const String collectibleEggFile = 'collectible_egg.png';
  
  // Backgrounds
  static const String backgroundSkyFile = 'background_sky.png';
  static const String backgroundHillsFile = 'background_hills.png';
  static const String backgroundGroundFile = 'background_ground.png';
  static const String backgroundFenceFile = 'background_fence.png';
  
  // UI
  static const String uiButtonPlayFile = 'ui_button_play.png';
  static const String uiButtonPauseFile = 'ui_button_pause.png';
  static const String uiButtonHomeFile = 'ui_button_home.png';
  static const String uiProgressBarFrameFile = 'ui_progress_bar_frame.png';

  // ============================================
  // PARALLAX LAYERS (ordered back to front)
  // ============================================
  
  /// Parallax layer configuration for background
  /// Order: Sky (slowest) → Hills (medium) → Ground (fastest)
  static const List<String> parallaxLayers = [
    backgroundSkyFile,
    backgroundHillsFile,
    backgroundGroundFile,
  ];
  
  /// Speed multipliers for each parallax layer (0.0 - 1.0)
  static const List<double> parallaxSpeeds = [
    0.1,  // Sky - moves very slowly
    0.4,  // Hills - moves at medium speed
    1.0,  // Ground - moves at game speed
  ];
}

/// Food item configuration
class FoodConfig {
  final String assetFile;
  final double fullnessValue;
  final String name;

  const FoodConfig({
    required this.assetFile,
    required this.fullnessValue,
    required this.name,
  });

  static const corn = FoodConfig(
    assetFile: Assets.foodCornFile,
    fullnessValue: 10.0,
    name: 'Corn',
  );

  static const worm = FoodConfig(
    assetFile: Assets.foodWormFile,
    fullnessValue: 20.0,
    name: 'Super Worm',
  );

  /// All food types for random spawning
  static const List<FoodConfig> all = [corn, worm];
}

/// Obstacle configuration
class ObstacleConfig {
  final String assetFile;
  final double fullnessPenalty;
  final double stunDuration;
  final double? speedModifier; // For mud puddle (slows player)
  final String name;

  const ObstacleConfig({
    required this.assetFile,
    required this.fullnessPenalty,
    required this.stunDuration,
    this.speedModifier,
    required this.name,
  });

  static const hayBale = ObstacleConfig(
    assetFile: Assets.obstacleHayBaleFile,
    fullnessPenalty: 15.0,
    stunDuration: 0.5,
    name: 'Hay Bale',
  );

  static const rock = ObstacleConfig(
    assetFile: Assets.obstacleRockFile,
    fullnessPenalty: 15.0,
    stunDuration: 0.5,
    name: 'Rock',
  );

  static const mudPuddle = ObstacleConfig(
    assetFile: Assets.obstacleMudPuddleFile,
    fullnessPenalty: 0.0, // No damage, just slows
    stunDuration: 0.0,
    speedModifier: 0.5, // Reduces speed by 50%
    name: 'Mud Puddle',
  );

  /// Basic obstacles (levels 1-6)
  static const List<ObstacleConfig> basic = [hayBale, rock];
  
  /// All obstacles including mud puddle (level 7+)
  static const List<ObstacleConfig> all = [hayBale, rock, mudPuddle];
}

/// Enemy configuration
class EnemyConfig {
  final String assetFile;
  final double fullnessPenalty;
  final double pushbackDistance;
  final String name;

  const EnemyConfig({
    required this.assetFile,
    required this.fullnessPenalty,
    required this.pushbackDistance,
    required this.name,
  });

  static const fox = EnemyConfig(
    assetFile: Assets.enemyFoxFile,
    fullnessPenalty: 20.0,
    pushbackDistance: 50.0,
    name: 'Naughty Fox',
  );
}

/// Player state sprites mapping
enum PlayerState {
  idle,
  running,
  jumping,
  hit,
}

extension PlayerStateAsset on PlayerState {
  String get assetFile {
    switch (this) {
      case PlayerState.idle:
        return Assets.chickenIdleFile;
      case PlayerState.running:
        return Assets.chickenRunFile;
      case PlayerState.jumping:
        return Assets.chickenJumpFile;
      case PlayerState.hit:
        return Assets.chickenDizzyFile;
    }
  }
}
