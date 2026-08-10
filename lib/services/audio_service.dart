import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'package:choco_blast_adventure/core/constants/asset_paths.dart';

/// Plays background music and sound effects. Gracefully no-ops if audio
/// assets are missing (so the game still runs without bundled audio files).
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // Dedicated pre-loaded pools for ZERO latency using SoundPool (lowLatency)
  final List<AudioPlayer> _matchPlayers = List.generate(8, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop)..setPlayerMode(PlayerMode.lowLatency));
  int _matchIdx = 0;

  final List<AudioPlayer> _swapPlayers = List.generate(5, (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop)..setPlayerMode(PlayerMode.lowLatency));
  int _swapIdx = 0;

  final AudioPlayer _btnPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop)..setPlayerMode(PlayerMode.lowLatency);
  final AudioPlayer _invalidPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop)..setPlayerMode(PlayerMode.lowLatency);
  final AudioPlayer _specialPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop)..setPlayerMode(PlayerMode.lowLatency);
  final AudioPlayer _victoryPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _losePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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
    await _victoryPlayer.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxVictory)));
    await _losePlayer.setSource(AssetSource(_formatAssetPath(AssetPaths.sfxLose)));

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
  void _playMatchPool(List<AudioPlayer> pool, int index, void Function(int) updateIndex, {int combo = 1}) {
    if (!sfxEnabled) return;
    try {
      final player = pool[index];
      updateIndex((index + 1) % pool.length);
      
      // Dynamic pitch escalation based on combo (from 1.0 up to 2.0x)
      double pitch = 1.0 + (combo - 1) * 0.08;
      if (pitch > 2.0) pitch = 2.0;

      // Fire synchronously for ZERO latency
      player.setPlaybackRate(pitch);
      player.seek(Duration.zero);
      player.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('sfx match pool unavailable: $e');
    }
  }

  void _playPool(List<AudioPlayer> pool, int index, void Function(int) updateIndex) {
    if (!sfxEnabled) return;
    try {
      final player = pool[index];
      updateIndex((index + 1) % pool.length);
      
      player.setPlaybackRate(1.0);
      player.seek(Duration.zero);
      player.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('sfx pool unavailable: $e');
    }
  }

  void _playSingle(AudioPlayer player) {
    if (!sfxEnabled) return;
    try {
      player.seek(Duration.zero);
      player.resume();
    } catch (e) {
      if (kDebugMode) debugPrint('sfx single unavailable: $e');
    }
  }

  void playMatch({int combo = 1}) => _playMatchPool(_matchPlayers, _matchIdx, (i) => _matchIdx = i, combo: combo);
  void playSwap() => _playPool(_swapPlayers, _swapIdx, (i) => _swapIdx = i);
  void playButton() => _playSingle(_btnPlayer);
  void playInvalid() => _playSingle(_invalidPlayer);
  void playSpecial() => _playSingle(_specialPlayer);
  
  void playVictory() => _playSingle(_victoryPlayer);
  
  void playLose() => _playSingle(_losePlayer);

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
