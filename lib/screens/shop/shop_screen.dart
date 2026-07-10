import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';

/// Professional shop screen — card grid with glass-morphism.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  static const _boosters = [
    _Booster('Extra Moves', 'Add 5 moves to your level', Icons.add_road_rounded, AppColors.candyGreen, '5 moves'),
    _Booster('Color Bomb', 'Start with a color bomb', Icons.auto_awesome_rounded, AppColors.candyPurple, '1x'),
    _Booster('Hammer', 'Remove any single tile', Icons.gpp_maybe_rounded, AppColors.candyOrange, '1x'),
    _Booster('Shuffle', 'Reshuffle the board', Icons.shuffle_rounded, AppColors.candyBlue, '3x'),
    _Booster('Lives', 'Get 5 extra lives', Icons.favorite_rounded, AppColors.candyRed, '+5'),
    _Booster('Score Boost', 'Start with 500 points', Icons.trending_up_rounded, AppColors.gold, '500'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), Color(0xFF0D0221)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Boosters', style: AppTextStyles.titleLarge),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              // ── Subtitle ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'No real payments',
                        style: TextStyle(color: AppColors.gold, fontSize: 12, fontFamily: 'Baloo2', fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Grid ────────────────────────────────────
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _boosters.length,
                  itemBuilder: (context, i) => _boosterCard(_boosters[i], i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boosterCard(_Booster b, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(color: b.color.withOpacity(0.08), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [b.color.withOpacity(0.3), b.color.withOpacity(0.1)],
              ),
              border: Border.all(color: b.color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(b.icon, color: b.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            b.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Baloo2',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            b.qty,
            style: TextStyle(
              color: b.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Baloo2',
            ),
          ),
          const Spacer(),
          // Equip button
          Container(
            width: double.infinity,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [b.color.withOpacity(0.3), b.color.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: b.color.withOpacity(0.3), width: 1),
            ),
            child: const Center(
              child: Text(
                'Equip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: 'Baloo2',
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}

class _Booster {
  final String name;
  final String desc;
  final IconData icon;
  final Color color;
  final String qty;
  const _Booster(this.name, this.desc, this.icon, this.color, this.qty);
}
