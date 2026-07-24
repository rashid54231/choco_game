import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/screens/gameplay/gameplay_screen.dart';
import 'package:choco_blast_adventure/screens/home/home_screen.dart';
import 'package:choco_blast_adventure/screens/level_map/level_map_screen.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/services/cache_service.dart';
import 'package:choco_blast_adventure/widgets/common/star_rating.dart';

/// Professional level complete — celebration with trophy animation.
class LevelCompleteScreen extends StatefulWidget {
  final LevelModel level;
  final int score;
  final int stars;

  const LevelCompleteScreen({
    super.key,
    required this.level,
    required this.score,
    required this.stars,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _confetti.play();
    _scaleController.forward();
    AudioService.instance.playVictory();
    CacheService.instance.completeLevel(widget.level.levelNumber);
    CacheService.instance.setLevelStars(widget.level.levelNumber, widget.stars);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextLevel = widget.level.levelNumber + 1;
    final hasNext = nextLevel <= 30;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0533), Color(0xFF0D0221), Color(0xFF0A0118)],
              ),
            ),
          ),

          // ── Confetti ─────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.gold,
                AppColors.candy,
                AppColors.candyPurple,
                AppColors.candyBlue,
                AppColors.candyGreen,
                AppColors.candyOrange,
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy
                ScaleTransition(
                  scale: CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 30, spreadRadius: 8),
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Center(child: Text('🏆', style: TextStyle(fontSize: 56))),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // Title
                const Text('Level Complete!', style: AppTextStyles.displayLarge)
                    .animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                // Stars
                StarRating(count: widget.stars, size: 56),

                const SizedBox(height: 28),

                // Stats card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      _statRow('Score', '${widget.score}', AppColors.gold),
                      const SizedBox(height: 12),
                      _statRow('Stars', '${widget.stars}', AppColors.candy),
                      const SizedBox(height: 12),
                      _statRow('Level', '${widget.level.levelNumber}', AppColors.candyPurple),
                    ],
                  ),
                ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Buttons
                if (hasNext)
                  _buildButton(
                    'Next Level',
                    AppColors.pinkButtonGradient,
                    () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => GameplayScreen(level: LevelModel.level(nextLevel)),
                        ),
                        (r) => false,
                      );
                    },
                  )
                else
                  _buildButton(
                    'All Levels Complete!',
                    AppColors.goldGradient,
                    () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (r) => false,
                      );
                    },
                  ),

                const SizedBox(height: 12),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSmallButton('Replay', AppColors.purpleGradient, () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => GameplayScreen(level: LevelModel.level(widget.level.levelNumber))),
                      );
                    }),
                    const SizedBox(width: 12),
                    _buildSmallButton('Level Map', AppColors.greenGradient, () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                        (r) => false,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontFamily: 'Baloo2')),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'Baloo2'),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.button),
        ),
      ),
    ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildSmallButton(String label, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
          ],
        ),
        child: Text(label, style: AppTextStyles.buttonSmall),
      ),
    ).animate(delay: 800.ms).fadeIn();
  }
}
