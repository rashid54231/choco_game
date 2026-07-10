import 'package:flutter/material.dart';

/// Professional candy-game color palette.
class AppColors {
  // ─── Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFFE91E7A);
  static const Color primaryLight = Color(0xFFF06BA8);
  static const Color primaryDark = Color(0xFFB8145E);

  // ─── Rich backgrounds ───────────────────────────────────
  static const Color bgDeep = Color(0xFF0D0221);
  static const Color bgDark = Color(0xFF150538);
  static const Color bgNavy = Color(0xFF1A1145);

  // ─── Teal / Aqua (splash / auth) ───────────────────────
  static const Color bgTeal = Color(0xFF00BFA5);
  static const Color bgTealDark = Color(0xFF00897B);
  static const Color bgTealLight = Color(0xFF64FFDA);

  // ─── Candy accent colours ───────────────────────────────
  static const Color candy = Color(0xFFFF6B9D);
  static const Color candyOrange = Color(0xFFFF9A3C);
  static const Color candyPurple = Color(0xFFAB47BC);
  static const Color candyBlue = Color(0xFF42A5F5);
  static const Color candyGreen = Color(0xFF66BB6A);
  static const Color candyYellow = Color(0xFFFFD54F);
  static const Color candyRed = Color(0xFFEF5350);

  // ─── Board ──────────────────────────────────────────────
  static const Color boardBg = Color(0xFF1E1145);
  static const Color boardBgDark = Color(0xFF150B35);
  static const Color boardBorder = Color(0xFF3A2570);

  // ─── Stars ──────────────────────────────────────────────
  static const Color starFilled = Color(0xFFFFD54F);
  static const Color starEmpty = Color(0xFF4A3080);

  // ─── Text ───────────────────────────────────────────────
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A0533);
  static const Color textMuted = Color(0xFF9E8EC0);
  static const Color textPink = Color(0xFFFF6B9D);

  // ─── Status ─────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color gold = Color(0xFFFFD54F);

  // ─── Path (level map) ───────────────────────────────────
  static const Color pathStripe = Color(0xFF6C5CE7);
  static const Color pathBase = Color(0xFF2D1B69);

  // ─── Tab bar ────────────────────────────────────────────
  static const Color tabBg = Color(0xFF1A0E3E);
  static const Color tabSelected = Color(0xFFFF6B9D);
  static const Color tabUnselected = Color(0xFF6C5CE7);

  // ─── Glass / Surface ────────────────────────────────────
  static const Color glassWhite = Color(0x15FFFFFF);
  static const Color glassBorder = Color(0x25FFFFFF);
  static const Color surface = Color(0xFF1E1145);
  static const Color surfaceLight = Color(0xFF2A1A5E);

  // ─── Gradients ──────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDeep, bgDark, bgNavy],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA5), Color(0xFF00897B), Color(0xFF004D40)],
  );

  static const LinearGradient pinkButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFE91E7A), Color(0xFFC2185B)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2), Color(0xFF4A148C)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD54F), Color(0xFFFFA726), Color(0xFFFF6F00)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC773), Color(0xFFFF9A3C), Color(0xFFE65100)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5), Color(0xFF0D47A1)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C), Color(0xFF1B5E20)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1145), Color(0xFF150B35)],
  );

  // ─── Shadows ────────────────────────────────────────────
  static List<BoxShadow> glowPink = [
    BoxShadow(color: primary.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
  ];
  static List<BoxShadow> glowGold = [
    BoxShadow(color: gold.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
  ];
  static List<BoxShadow> glowPurple = [
    BoxShadow(color: candyPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2),
  ];
}
