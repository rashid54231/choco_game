import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:choco_blast_adventure/core/constants/asset_paths.dart';

/// Plays background music and sound effects. Gracefully no-ops if audio
/// assets are missing (so the game still runs without bundled audio files).
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // Dedicated pre-loaded pools for ZERO latency
  final List<AudioPlayer> _matchPlayers = List.generate(8, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  int _matchIdx = 0;

  final List<AudioPlayer> _swapPlayers = List.generate(5, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop));
  int _swapIdx = 0;

  final AudioPlayer _btnPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _invalidPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _specialPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  bool musicEnabled = true;
  bool sfxEnabled = true;

  String _formatAssetPath(String path) {
    if (path.startsWith('assets/')) {
      return path.substring('assets/'.length);
    }
    return path;
  }

  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    
    // PRE-LOAD all critical sources to eliminate decoding delay (Android MediaPlayer limitation)
    for (var p in _matchPlayers) {
      await p.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxMatch)));
    }
    for (var p in _swapPlayers) {
      await p.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxSwap)));
    }
    
    await _btnPlayer.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxButton)));
    await _invalidPlayer.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxInvalid)));
    await _specialPlayer.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxSpecial)));

    playBackgroundMusic();
  }

  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.play(AssetSource(_formatAssetPath(AssetPaths.bgMusic)));
    } catch (e) {
      if (kDebugMode) debugPrint('bg music unavailable: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  // Fire and forget using pre-loaded sources for absolute 0ms delay
  void _playPool(List<AudioPlayer> pool, int index, void Function(int) updateIndex) {
    if (!sfxEnabled) return;
    try {
      final player = pool[index];
      updateIndex((index + 1) % pool.length);
      if (player.state == PlayerState.playing || player.state == PlayerState.paused) {
        player.seek(Duration.zero);
        player.resume();
      } else {
        player.resume();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sfx pool unavailable: $e');
    }
  }

  void _playSingle(AudioPlayer player) {
    if (!sfxEnabled) return;
    try {
      if (player.state == PlayerState.playing || player.state == PlayerState.paused) {
        player.seek(Duration.zero);
        player.resume();
      } else {
        player.resume();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sfx single unavailable: $e');
    }
  }

  void playMatch() => _playPool(_matchPlayers, _matchIdx, (i) => _matchIdx = i);
  void playSwap() => _playPool(_swapPlayers, _swapIdx, (i) => _swapIdx = i);
  void playButton() => _playSingle(_btnPlayer);
  void playInvalid() => _playSingle(_invalidPlayer);
  void playSpecial() => _playSingle(_specialPlayer);
  
  // For victory/lose, we can just use dynamic play since they aren't rapid/spammy
  void playVictory() {
    if (!sfxEnabled) return;
    AudioPlayer().play(AssetSource(_formatAssetPath(AssetPaths.sfxVictory)));
  }
  
  void playLose() {
    if (!sfxEnabled) return;
    AudioPlayer().play(AssetSource(_formatAssetPath(AssetPaths.sfxLose)));
  }

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
