import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/screens/gameplay/gameplay_screen.dart';
import 'package:choco_blast_adventure/screens/home/home_screen.dart';
import 'package:choco_blast_adventure/screens/level_map/level_map_screen.dart';

/// Professional level failed — encouraging dark UI with retry.
class LevelFailedScreen extends StatelessWidget {
  final LevelModel level;
  final int score;

  const LevelFailedScreen({super.key, required this.level, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), Color(0xFF0D0221), Color(0xFF0A0118)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.candyOrange.withOpacity(0.3), AppColors.candyOrange.withOpacity(0.1)],
                    ),
                    border: Border.all(color: AppColors.candyOrange.withOpacity(0.3), width: 2),
                  ),
                  child: const Center(
                    child: Text('😔', style: TextStyle(fontSize: 48)),
                  ),
                ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),

                const SizedBox(height: 20),

                const Text('Out of Moves!', style: AppTextStyles.displayLarge)
                    .animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 8),

                Text(
                  "Don't give up! Try again.",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontFamily: 'Baloo2'),
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // Score card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.score_rounded, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Score: $score',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, fontFamily: 'Baloo2', fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                const SizedBox(height: 32),

                // Retry button
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => GameplayScreen(level: LevelModel.level(level.levelNumber))),
                  ),
                  child: Container(
                    width: 240,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkButtonGradient,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text('Retry (1 Life)', style: AppTextStyles.button),
                      ],
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                // Level Map button
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                    (r) => false,
                  ),
                  child: Container(
                    width: 240,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: AppColors.candyPurple.withOpacity(0.3), blurRadius: 12),
                      ],
                    ),
                    child: const Center(
                      child: Text('Level Map', style: AppTextStyles.buttonSmall),
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(),

                const SizedBox(height: 12),

                // Home button
                GestureDetector(
                  onTap: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (r) => false,
                  ),
                  child: Container(
                    width: 240,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Center(
                      child: Text('Back to Home', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Baloo2', fontWeight: FontWeight.w600)),
                    ),
                  ),
                ).animate(delay: 700.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
