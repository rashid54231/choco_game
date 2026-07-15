import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';

class DailyRewardDialog extends ConsumerWidget {
  const DailyRewardDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF150B35)],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40, spreadRadius: 10),
            BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF9A3C)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF9A3C).withOpacity(0.5), blurRadius: 20, spreadRadius: 4),
                ],
              ),
              child: const Center(
                child: Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 50),
              ),
            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Daily Reward!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'Baloo2',
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Thanks for playing today! Here is your daily gift.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontFamily: 'Baloo2',
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            // Reward Item
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD54F).withOpacity(0.2),
                    ),
                    child: const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD54F), size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('500 Coins', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Baloo2')),
                      Text('Use for boosters!', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 32),

            // Claim Button
            GestureDetector(
              onTap: () async {
                final notifier = ref.read(profileProvider.notifier);
                await notifier.claimDailyReward();
                if (context.mounted) Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppColors.candyGreen.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'CLAIM NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
