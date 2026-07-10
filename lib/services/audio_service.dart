import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:choco_blast_adventure/core/constants/asset_paths.dart';

/// Plays background music and sound effects. Gracefully no-ops if audio
/// assets are missing (so the game still runs without bundled audio files).
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool musicEnabled = true;
  bool sfxEnabled = true;

  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(AssetPaths.bgMusic));
    } catch (e) {
      if (kDebugMode) debugPrint('bg music unavailable: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> _playSfx(String path) async {
    if (!sfxEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(path));
    } catch (e) {
      if (kDebugMode) debugPrint('sfx unavailable: $e');
    }
  }

  Future<void> playMatch() => _playSfx(AssetPaths.sfxMatch);
  Future<void> playSwap() => _playSfx(AssetPaths.sfxSwap);
  Future<void> playInvalid() => _playSfx(AssetPaths.sfxInvalid);
  Future<void> playSpecial() => _playSfx(AssetPaths.sfxSpecial);
  Future<void> playButton() => _playSfx(AssetPaths.sfxButton);

  void setMusicEnabled(bool enabled) {
    musicEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    } else {
      playBackgroundMusic();
    }
  }

  void setSfxEnabled(bool enabled) => sfxEnabled = enabled;
}
