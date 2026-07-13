import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';

/// Professional shop screen — card grid with glass-morphism and coin purchasing.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static const _boosters = [
    _Booster('Extra Moves', 'Add 5 moves to your level', Icons.add_road_rounded, AppColors.candyGreen, 'Get 1 Move Booster', 150, 'extra_moves'),
    _Booster('Color Bomb', 'Place a color bomb on board', Icons.auto_awesome_rounded, AppColors.candyPurple, 'Get 1 Bomb Booster', 250, 'color_bomb'),
    _Booster('Hammer', 'Remove any single tile', Icons.gpp_maybe_rounded, AppColors.candyOrange, 'Get 1 Hammer Booster', 200, 'hammer'),
    _Booster('Shuffle Pack', 'Reshuffle the board', Icons.shuffle_rounded, AppColors.candyBlue, 'Get 3 Shuffle Boosters', 100, 'shuffle'),
    _Booster('Lives Refill', 'Get 5 extra lives', Icons.favorite_rounded, AppColors.candyRed, 'Refill up to 5 lives', 150, 'lives'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final coins = profile?.coins ?? 0;

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
                        child: Text('Boosters Shop', style: AppTextStyles.titleLarge),
                      ),
                    ),
                    // Coins Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$coins',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Baloo2'),
                          ),
                        ],
                      ),
                    ),
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
                        'Purchase boosters using in-game coins!',
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
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _boosters.length,
                  itemBuilder: (context, i) => _boosterCard(context, ref, _boosters[i], i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _boosterCard(BuildContext context, WidgetRef ref, _Booster b, int index) {
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
          const SizedBox(height: 10),
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
          const SizedBox(height: 2),
          Text(
            b.qty,
            style: TextStyle(
              color: b.color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              fontFamily: 'Baloo2',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Buy button
          GestureDetector(
            onTap: () async {
              final profileNotifier = ref.read(profileProvider.notifier);
              final success = await profileNotifier.buyBooster(b.type, b.cost);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchased ${b.name} successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not enough coins! Clear levels to earn more.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [b.color.withOpacity(0.4), b.color.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: b.color.withOpacity(0.4), width: 1),
              ),
              child: Center(
                child: Text(
                  'Buy (${b.cost} 🪙)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Baloo2',
                  ),
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
  final int cost;
  final String type;
  const _Booster(this.name, this.desc, this.icon, this.color, this.qty, this.cost, this.type);
}
