import 'package:hive_ce_flutter/hive_flutter.dart';

/// StorageService - Handles all persistent data storage for Cluck Rush
/// 
/// Uses Hive for fast, local key-value storage.
/// Stores: level progress, egg collection, audio settings, and unlocked skins.
class StorageService {
  StorageService._(); // Private constructor for singleton

  static final StorageService _instance = StorageService._();
  static StorageService get instance => _instance;

  // Box name for all game data
  static const String _boxName = 'cluck_rush_data';

  // Keys for stored data
  static const String keyHighestLevel = 'highest_level';
  static const String keyTotalEggs = 'total_eggs';
  static const String keyUnlockedSkins = 'unlocked_skins';
  static const String keyMusicEnabled = 'music_enabled';
  static const String keySfxEnabled = 'sfx_enabled';
  static const String keyLevelStars = 'level_stars'; // Map of level -> stars (1-3)

  late Box _box;
  bool _isInitialized = false;

  /// Initialize the storage service
  /// Must be called before accessing any data
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _isInitialized = true;
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  // ============================================
  // LEVEL PROGRESS
  // ============================================

  /// Get the highest level reached (default: 1)
  int get highestLevel => _box.get(keyHighestLevel, defaultValue: 1);

  /// Set the highest level reached
  Future<void> setHighestLevel(int level) async {
    final current = highestLevel;
    if (level > current) {
      await _box.put(keyHighestLevel, level);
    }
  }

  /// Get stars earned for a specific level (0 if not completed)
  int getStarsForLevel(int level) {
    final Map<dynamic, dynamic> starsMap = _box.get(keyLevelStars, defaultValue: {});
    return starsMap[level] ?? 0;
  }

  /// Set stars earned for a specific level
  /// Only updates if new stars are higher than existing
  Future<void> setStarsForLevel(int level, int stars) async {
    final Map<dynamic, dynamic> currentMap = _box.get(keyLevelStars, defaultValue: {});
    final Map<int, int> starsMap = Map<int, int>.from(
      currentMap.map((k, v) => MapEntry(k as int, v as int)),
    );
    
    final currentStars = starsMap[level] ?? 0;
    if (stars > currentStars) {
      starsMap[level] = stars;
      await _box.put(keyLevelStars, starsMap);
    }
  }

  /// Calculate stars based on fullness percentage
  /// - 1 Star: Completed
  /// - 2 Stars: Completed with > 50% fullness remaining
  /// - 3 Stars: Completed with > 80% fullness remaining
  static int calculateStars(double fullnessPercent) {
    if (fullnessPercent > 80) return 3;
    if (fullnessPercent > 50) return 2;
    return 1;
  }

  // ============================================
  // EGG COLLECTION
  // ============================================

  /// Get total eggs collected
  int get totalEggs => _box.get(keyTotalEggs, defaultValue: 0);

  /// Add eggs to the collection
  Future<void> addEggs(int count) async {
    final current = totalEggs;
    await _box.put(keyTotalEggs, current + count);
  }

  /// Check if player earned an egg (fullness > 50% at victory)
  static bool earnedEgg(double fullnessPercent) => fullnessPercent > 50;

  // ============================================
  // UNLOCKED SKINS
  // ============================================

  /// Get list of unlocked skin IDs
  List<String> get unlockedSkins {
    final List<dynamic> skins = _box.get(keyUnlockedSkins, defaultValue: ['default']);
    return skins.cast<String>();
  }

  /// Unlock a new skin
  Future<void> unlockSkin(String skinId) async {
    final skins = unlockedSkins;
    if (!skins.contains(skinId)) {
      skins.add(skinId);
      await _box.put(keyUnlockedSkins, skins);
    }
  }

  /// Check if a skin is unlocked
  bool isSkinUnlocked(String skinId) => unlockedSkins.contains(skinId);

  // ============================================
  // AUDIO SETTINGS
  // ============================================

  /// Check if music is enabled (default: true)
  bool get isMusicEnabled => _box.get(keyMusicEnabled, defaultValue: true);

  /// Set music enabled state
  Future<void> setMusicEnabled(bool enabled) async {
    await _box.put(keyMusicEnabled, enabled);
  }

  /// Check if SFX is enabled (default: true)
  bool get isSfxEnabled => _box.get(keySfxEnabled, defaultValue: true);

  /// Set SFX enabled state
  Future<void> setSfxEnabled(bool enabled) async {
    await _box.put(keySfxEnabled, enabled);
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Record a completed level
  /// - Updates highest level if needed
  /// - Updates stars for the level
  /// - Awards egg if fullness > 50%
  Future<void> recordLevelCompletion({
    required int level,
    required double fullnessPercent,
  }) async {
    // Update highest level
    await setHighestLevel(level + 1);

    // Update stars
    final stars = calculateStars(fullnessPercent);
    await setStarsForLevel(level, stars);

    // Award egg if earned
    if (earnedEgg(fullnessPercent)) {
      await addEggs(1);
    }
  }

  /// Get total stars earned across all levels
  int get totalStars {
    final Map<dynamic, dynamic> starsMap = _box.get(keyLevelStars, defaultValue: {});
    return starsMap.values.fold<int>(0, (sum, stars) => sum + (stars as int));
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(int level) => level <= highestLevel;

  /// Clear all data (for debugging/reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
}

