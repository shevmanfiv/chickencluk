import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import '../../services/storage_service.dart';

/// Handles all audio playback for the game
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;

  bool get isSfxEnabled => _sfxEnabled;
  bool get isMusicEnabled => _musicEnabled;

  /// Initialize audio cache and load settings from storage
  Future<void> init() async {
    FlameAudio.bgm.initialize();

    // Load settings from storage
    final storage = StorageService.instance;
    if (storage.isInitialized) {
      _musicEnabled = storage.isMusicEnabled;
      _sfxEnabled = storage.isSfxEnabled;
    }

    // Preload sounds
    await FlameAudio.audioCache.loadAll([
      'mainmenuSong.mp3',
      'playSong.mp3',
      'Jump.mp3',
      'eating.mp3',
      'wrongmove.mp3',
      'chickenCluck.mp3',
      'winLayegg.mp3',
    ]);
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
    // Persist setting
    StorageService.instance.setSfxEnabled(enabled);
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    // Persist setting
    StorageService.instance.setMusicEnabled(enabled);
    if (!enabled) {
      stopMusic();
    }
  }

  // Background music
  void playMenuMusic() {
    if (!_musicEnabled) return;
    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.stop();
      }
      FlameAudio.bgm.play('mainmenuSong.mp3', volume: 0.5);
    } catch (e) {
      // Handle potential audio errors
      debugPrint('Error playing menu music: $e');
    }
  }

  void playGameMusic() {
    if (!_musicEnabled) return;
    try {
      if (FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.stop();
      }
      FlameAudio.bgm.play('playSong.mp3', volume: 0.4);
    } catch (e) {
      debugPrint('Error playing game music: $e');
    }
  }

  void stopMusic() {
    FlameAudio.bgm.stop();
  }

  // Sound effects
  void playJump() {
    if (!_sfxEnabled) return;
    FlameAudio.play('Jump.mp3', volume: 0.6);
  }

  void playEat() {
    if (!_sfxEnabled) return;
    FlameAudio.play('eating.mp3', volume: 0.7);
  }

  void playHit() {
    if (!_sfxEnabled) return;
    FlameAudio.play('wrongmove.mp3', volume: 0.8);
  }

  void playCluck() {
    if (!_sfxEnabled) return;
    FlameAudio.play('chickenCluck.mp3', volume: 0.5);
  }

  void playVictory() {
    if (!_sfxEnabled) return;
    FlameAudio.play('winLayegg.mp3', volume: 0.8);
  }
}

// End of AudioManager
