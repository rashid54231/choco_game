import 'dart:math' as math;
import 'dart:ui';
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
          // ── Premium Blurred Background ──────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/candy_map_bg.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Color(0x770D0221), BlendMode.darken),
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
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

                // ── Glassmorphism Button Panel ────────────────────────────────
                Container(
                  width: screenW * 0.85,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 15)),
                      BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildButton(
                        label: 'Play',
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF8A65), Color(0xFFF4511E)],
                        ),
                        shadow: const Color(0xFFBF360C),
                        icon: Icons.play_arrow_rounded,
                        width: double.infinity,
                        height: 58,
                        delay: 500,
                        onTap: () => _playGame(context),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        label: 'Level Map',
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                        ),
                        shadow: const Color(0xFF1B5E20),
                        icon: Icons.map_rounded,
                        width: double.infinity,
                        height: 58,
                        delay: 650,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LevelMapScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        label: 'Retrieve Progress',
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                        ),
                        shadow: const Color(0xFF0D47A1),
                        icon: Icons.cloud_download_rounded,
                        width: double.infinity,
                        height: 58,
                        delay: 800,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),

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
                          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12),
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
        // Premium 3D Strawberry Icon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A65), Color(0xFFF4511E), Color(0xFFBF360C)],
            ),
            border: Border.all(color: const Color(0xFFFFD54F), width: 2.5),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF8A65).withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 6),
              BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 8)),
            ],
          ),
          child: Stack(
            children: [
              // Inner glossy highlight
              Positioned(
                top: 4,
                left: 14,
                right: 14,
                height: 35,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
              ),
              const Center(
                child: Text('🍓', style: TextStyle(fontSize: 48, shadows: [
                  Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
                ])),
              ),
            ],
          ),
        ).animate(delay: 200.ms).fadeIn(duration: 500.ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),

        const SizedBox(height: 12),

        // Title
        Text(
          'Choco',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 56,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFF8F00)],
                stops: [0.0, 0.4, 1.0],
              ).createShader(const Rect.fromLTWH(0, 0, 250, 60)),
            shadows: const [
              Shadow(color: Color(0xFFFF8F00), offset: Offset(0, 3), blurRadius: 2),
              Shadow(color: Color(0x99000000), offset: Offset(0, 8), blurRadius: 12),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0)
         .animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -2, end: 2, duration: 2.seconds),

        Text(
          'Blast',
          style: TextStyle(
            fontFamily: 'Baloo2',
            fontSize: 56,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFF80AB), Color(0xFFF50057), Color(0xFF880E4F)],
                stops: [0.0, 0.4, 1.0],
              ).createShader(const Rect.fromLTWH(0, 0, 250, 60)),
            shadows: const [
              Shadow(color: Color(0xFF880E4F), offset: Offset(0, 3), blurRadius: 2),
              Shadow(color: Color(0x99000000), offset: Offset(0, 8), blurRadius: 12),
            ],
          ),
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0)
         .animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -2, end: 2, duration: 2.seconds, delay: 500.ms),

        const SizedBox(height: 8),

        // "Adventure" tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppColors.purpleGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.candyPurple.withValues(alpha: 0.3), blurRadius: 10),
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
        ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.elasticOut)
         .animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1.seconds),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2), // Glossy border highlight
          boxShadow: [
            BoxShadow(color: shadow.withValues(alpha: 0.6), blurRadius: 0, offset: const Offset(0, 6)), // Solid 3D edge
            BoxShadow(color: shadow.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 10)), // Soft shadow
          ],
        ),
        child: Stack(
          children: [
            // Inner glossy highlight
            Positioned(
              top: 2,
              left: 20,
              right: 20,
              height: height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 28, shadows: const [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))]),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack)
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1500.ms, color: Colors.white.withValues(alpha: 0.5))
        .then(delay: 2000.ms);
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
              colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.1)],
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
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(level: LevelModel.level(nextLevel)),
      ),
    );
  }
}
//home
//homeeeeee