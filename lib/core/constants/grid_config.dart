/// Default gameplay grid configuration.
class GridConfig {
  /// Number of columns (and rows for square boards).
  final int size;
  final int rows;
  final int cols;

  const GridConfig({required this.size, required this.rows, required this.cols});

  /// Standard 8x8 board used by most levels.
  static const GridConfig standard = GridConfig(size: 8, rows: 8, cols: 8);
}

/// Miscelaneous game-wide numeric constants.
class GameConstants {
  static const int startingLives = 5;
  static const int maxLives = 5;

  /// Minutes between life regenerations.
  static const int lifeRegenMinutes = 30;

  /// Combo multiplier cap (so scores don't explode).
  static const int maxComboMultiplier = 3;

  /// Minimum match length.
  static const int minMatch = 3;

  /// Score awarded for a single basic tile clear.
  static const int baseTileScore = 20;
}
