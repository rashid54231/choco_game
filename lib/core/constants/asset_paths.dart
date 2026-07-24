/// Centralized asset paths.
///
/// NOTE: This game uses NO copyrighted art. Tile visuals are drawn with
/// Flutter vector painting + gradients (see [TileWidget]). The assets below
/// are optional audio / decorative files. If the files are missing the
/// [AudioService] gracefully no-ops.
class AssetPaths {
  // Audio
  static const String bgMusic = 'assets/audio/bg_music.wav';
  static const String sfxMatch = 'assets/audio/match.wav';
  static const String sfxSwap = 'assets/audio/swap.wav';
  static const String sfxInvalid = 'assets/audio/invalid.wav';
  static const String sfxSpecial = 'assets/audio/special.wav';
  static const String sfxButton = 'assets/audio/button.wav';
  static const String sfxVictory = 'assets/audio/victory.wav';
  static const String sfxLose = 'assets/audio/lose.wav';

  // Decorative images (optional)
  static const String splashLogo = 'assets/images/logo.png';
  static const String mapBackground = 'assets/images/map_bg.png';
}
