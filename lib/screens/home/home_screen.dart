import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/screens/auth/login_screen.dart';
import 'package:choco_blast_adventure/screens/gameplay/gameplay_screen.dart';
import 'package:choco_blast_adventure/screens/level_map/level_map_screen.dart';
import 'package:choco_blast_adventure/screens/settings/settings_screen.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/services/cache_service.dart';
import 'package:choco_blast_adventure/screens/home/daily_reward_dialog.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';

/// Professional home screen — dark cosmic candy theme with glass-morphism UI.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
    });
  }
  
  void _checkDailyReward() {
    final profile = ref.read(profileProvider);
    if (profile == null) return;
    
    final lastReward = profile.lastDailyReward;
    final now = DateTime.now();
    bool shouldShow = false;
    
    if (lastReward == null) {
      shouldShow = true;
    } else {
      // Check if last reward was yesterday or earlier
      if (now.difference(lastReward).inHours >= 24 || now.day != lastReward.day) {
        shouldShow = true;
      }
    }
    
    if (shouldShow) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DailyRewardDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated gradient background ──────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0533), Color(0xFF0D0221), Color(0xFF0A0118)],
              ),
            ),
          ),

          // ── Floating candy decorations ────────────────────
          ..._buildFloatingCandy(),

          // ── Main content ──────────────────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ── Logo section ─────────────────────────────
                _buildLogo(),

                const Spacer(flex: 2),

                // ── Buttons ──────────────────────────────────
                Center(
                  child: _buildButton(
                    label: 'Play',
                    gradient: AppColors.pinkButtonGradient,
                    shadow: AppColors.primary,
                    icon: Icons.play_arrow_rounded,
                    width: screenW * 0.65,
                    height: 60,
                    delay: 500,
                    onTap: () => _playGame(context),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: _buildButton(
                    label: 'Level Map',
                    gradient: AppColors.greenGradient,
                    shadow: AppColors.candyGreen,
                    icon: Icons.map_rounded,
                    width: screenW * 0.55,
                    height: 50,
                    delay: 650,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: _buildButton(
                    label: 'Retrieve Progress',
                    gradient: AppColors.blueGradient,
                    shadow: AppColors.candyBlue,
                    icon: Icons.cloud_download_rounded,
                    width: screenW * 0.55,
                    height: 50,
                    delay: 800,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ── Settings button ──────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.glassWhite,
                        border: Border.all(color: AppColors.glassBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
                        ],
                      ),
                      child: const Icon(Icons.settings_rounded, color: Colors.white70, size: 24),
                    ),
                  ).animate(delay: 1000.ms).fadeIn().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Chocolate icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8D6E63), Color(0xFF5D4037), Color(0xFF3E2723)],
            ),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.25), blurRadius: 24, spreadRadius: 4),
              BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: const Center(child: Text('🍫', style: TextStyle(fontSize: 40))),
        ).animate(delay: 200.ms).fadeIn(duration: 500.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),

        const SizedBox(height: 16),

        // Title
        Text(
          'Choco',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 52,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFFD54F), Color(0xFFFFA726)],
              ).createShader(const Rect.fromLTWH(0, 0, 250, 60)),
            shadows: const [
              Shadow(color: Color(0x44FFA726), offset: Offset(0, 4), blurRadius: 12),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),

        Text(
          'Blast',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 52,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFE91E7A)],
              ).createShader(const Rect.fromLTWH(0, 0, 250, 60)),
            shadows: const [
              Shadow(color: Color(0x44E91E7A), offset: Offset(0, 4), blurRadius: 12),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0),

        const SizedBox(height: 4),

        // "Adventure" tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.candyPurple.withOpacity(0.3), blurRadius: 10),
            ],
          ),
          child: const Text(
            'ADVENTURE',
            style: TextStyle(
              fontFamily: 'Baloo2',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 5,
            ),
          ),
        ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required LinearGradient gradient,
    required Color shadow,
    required IconData icon,
    required double width,
    required double height,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.playButton();
        onTap();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: [
            BoxShadow(color: shadow.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Baloo2',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack)
        .then()
        .shimmer(duration: 2000.ms, delay: 1500.ms);
  }

  List<Widget> _buildFloatingCandy() {
    final rng = math.Random(42);
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF6B9D),
      const Color(0xFFAB47BC),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFF9A3C),
    ];

    return List.generate(15, (i) {
      final size = 10.0 + rng.nextDouble() * 16;
      final color = colors[rng.nextInt(colors.length)];
      return Positioned(
        left: rng.nextDouble() * 400,
        top: rng.nextDouble() * 800,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
            ),
          ),
        ).animate(
          onPlay: (c) => c.repeat(reverse: true),
        ).moveY(
          begin: 0,
          end: -15 - rng.nextDouble() * 25,
          duration: Duration(milliseconds: 3000 + rng.nextInt(2000)),
          curve: Curves.easeInOut,
        ),
      );
    });
  }

  void _playGame(BuildContext context) async {
    final nextLevel = await CacheService.instance.getNextLevel();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(level: LevelModel.level(nextLevel)),
      ),
    );
  }
}
