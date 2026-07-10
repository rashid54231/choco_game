import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Professional candy-game text styles.
class AppTextStyles {
  static const String fontFamily = 'Baloo2';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    height: 1.1,
    shadows: [
      Shadow(color: Color(0x66000000), offset: Offset(0, 4), blurRadius: 12),
      Shadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 4),
    ],
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.2,
    shadows: [Shadow(color: Color(0x44000000), offset: Offset(0, 3), blurRadius: 8)],
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  static const TextStyle pinkHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.candy,
    shadows: [Shadow(color: Color(0x44FF6B9D), offset: Offset(0, 2), blurRadius: 8)],
  );

  static const TextStyle goldHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.gold,
    shadows: [
      Shadow(color: Color(0x66FFD54F), offset: Offset(0, 3), blurRadius: 10),
      Shadow(color: Color(0x33FFA000), offset: Offset(0, 1), blurRadius: 4),
    ],
  );

  static const TextStyle chipLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.8,
  );
}
