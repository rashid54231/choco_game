/// Centralized asset paths.
///
/// NOTE: This game uses NO copyrighted art. Tile visuals are drawn with
/// Flutter vector painting + gradients (see [TileWidget]). The assets below
/// are optional audio / decorative files. If the files are missing the
/// [AudioService] gracefully no-ops.
class AssetPaths {
  // Audio
  static const String bgMusic = 'assets/audio/bg_music.mp3';
  static const String sfxMatch = 'assets/audio/match.mp3';
  static const String sfxSwap = 'assets/audio/swap.mp3';
  static const String sfxInvalid = 'assets/audio/invalid.mp3';
  static const String sfxSpecial = 'assets/audio/special.mp3';
  static const String sfxButton = 'assets/audio/button.mp3';

  // Decorative images (optional)
  static const String splashLogo = 'assets/images/logo.png';
  static const String mapBackground = 'assets/images/map_bg.png';
}
