import 'package:flutter/material.dart';

class LevelTheme {
  final List<Color> backgroundGradient;
  final List<Color> hudGradient;
  final Color hudBorderColor;
  final Color boardBackgroundColor;
  final Color boardBorderColor;
  final List<Color> particleColors;
  final double particleAnimationSpeed;

  const LevelTheme({
    required this.backgroundGradient,
    required this.hudGradient,
    required this.hudBorderColor,
    required this.boardBackgroundColor,
    required this.boardBorderColor,
    required this.particleColors,
    required this.particleAnimationSpeed,
  });
}

class LevelThemeEngine {
  // 1-10: Choco Forest
  static const LevelTheme chocoForest = LevelTheme(
    backgroundGradient: [Color(0xFF2E0854), Color(0xFF150538)],
    hudGradient: [Color(0xFF2D1B69), Color(0xFF1E1145)],
    hudBorderColor: Color(0xFF6C5CE7),
    boardBackgroundColor: Color(0x1A000000), // Colors.black.withOpacity(0.1)
    boardBorderColor: Color(0xFF6C5CE7),
    particleColors: [Color(0xFFFFD54F), Color(0xFFFF9A3C), Color(0xFFE91E7A)],
    particleAnimationSpeed: 1.0,
  );

  // 11-20: Candy Canyon
  static const LevelTheme candyCanyon = LevelTheme(
    backgroundGradient: [Color(0xFF880E4F), Color(0xFF4A148C)],
    hudGradient: [Color(0xFFC2185B), Color(0xFF7B1FA2)],
    hudBorderColor: Color(0xFFFF8A80),
    boardBackgroundColor: Color(0x26FFFFFF), // Colors.white.withOpacity(0.15)
    boardBorderColor: Color(0xFFFF4081),
    particleColors: [Color(0xFFFF80AB), Color(0xFFFFD180), Color(0xFFF8BBD0)],
    particleAnimationSpeed: 1.2,
  );

  // 21-30: Jelly Jungle
  static const LevelTheme jellyJungle = LevelTheme(
    backgroundGradient: [Color(0xFF1B5E20), Color(0xFF004D40)],
    hudGradient: [Color(0xFF2E7D32), Color(0xFF00695C)],
    hudBorderColor: Color(0xFFA5D6A7),
    boardBackgroundColor: Color(0x26000000),
    boardBorderColor: Color(0xFF66BB6A),
    particleColors: [Color(0xFFAED581), Color(0xFFFFF59D), Color(0xFF81C784)],
    particleAnimationSpeed: 1.5,
  );

  // 31-40: Ice Cream Peaks
  static const LevelTheme iceCreamPeaks = LevelTheme(
    backgroundGradient: [Color(0xFF01579B), Color(0xFF1A237E)],
    hudGradient: [Color(0xFF0277BD), Color(0xFF283593)],
    hudBorderColor: Color(0xFF81D4FA),
    boardBackgroundColor: Color(0x1AFFFFFF),
    boardBorderColor: Color(0xFF29B6F6),
    particleColors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE), Color(0xFF81D4FA)],
    particleAnimationSpeed: 1.8,
  );

  // 41+: Cosmic Bakery
  static const LevelTheme cosmicBakery = LevelTheme(
    backgroundGradient: [Color(0xFF000000), Color(0xFF311B92)],
    hudGradient: [Color(0xFF1A237E), Color(0xFF4A148C)],
    hudBorderColor: Color(0xFFB388FF),
    boardBackgroundColor: Color(0x33000000),
    boardBorderColor: Color(0xFF7C4DFF),
    particleColors: [Color(0xFFD1C4E9), Color(0xFFB388FF), Color(0xFFEA80FC)],
    particleAnimationSpeed: 2.2,
  );

  static LevelTheme getThemeForLevel(int levelNumber) {
    if (levelNumber <= 10) return chocoForest;
    if (levelNumber <= 20) return candyCanyon;
    if (levelNumber <= 30) return jellyJungle;
    if (levelNumber <= 40) return iceCreamPeaks;
    return cosmicBakery;
  }
}
