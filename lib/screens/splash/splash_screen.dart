import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/screens/home/home_screen.dart';

/// Professional splash — dark backdrop, animated chocolate logo, particle effects.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _route();
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated radial gradient background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      math.sin(t * 2 * math.pi) * 0.3,
                      math.cos(t * 2 * math.pi) * 0.2,
                    ),
                    radius: 1.4,
                    colors: const [
                      Color(0xFF2D1B69),
                      Color(0xFF150538),
                      Color(0xFF0D0221),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating candy particles
          ...List.generate(20, (i) => _floatingCandy(i)),

          // Center logo
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium 3D Strawberry Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF8A65), Color(0xFFF4511E), Color(0xFFBF360C)],
                    ),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 3),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFF8A65).withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 8),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner glossy glass highlight
                      Positioned(
                        top: 6,
                        left: 18,
                        right: 18,
                        height: 45,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          '🍓',
                          style: TextStyle(
                            fontSize: 64,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),

                const SizedBox(height: 16),

                // "Choco" text (Premium Gold 3D style)
                Text(
                  'Choco',
                  style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFF8F00)],
                        stops: [0.0, 0.4, 1.0],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 80)),
                    shadows: const [
                      Shadow(color: Color(0xFFFF8F00), offset: Offset(0, 3), blurRadius: 2), // 3D edge
                      Shadow(color: Color(0x99000000), offset: Offset(0, 10), blurRadius: 16), // Deep shadow
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                // "Blast" text (Premium Pink 3D style)
                Text(
                  'Blast',
                  style: TextStyle(
                    fontFamily: 'Baloo2',
                    fontSize: 76,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Color(0xFFFF80AB), Color(0xFFF50057), Color(0xFF880E4F)],
                        stops: [0.0, 0.4, 1.0],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 80)),
                    shadows: const [
                      Shadow(color: Color(0xFF880E4F), offset: Offset(0, 3), blurRadius: 2),
                      Shadow(color: Color(0x99000000), offset: Offset(0, 10), blurRadius: 16),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                // "Adventure" badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF7B1FA2).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Text(
                    'ADVENTURE',
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), curve: Curves.easeOutBack),
              ],
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ).animate(delay: 1000.ms).fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _floatingCandy(int index) {
    final rng = math.Random(index);
    final size = 8.0 + rng.nextDouble() * 12;
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF6B9D),
      const Color(0xFFAB47BC),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFF9A3C),
    ];
    final color = colors[rng.nextInt(colors.length)];

    return Positioned(
      left: rng.nextDouble() * MediaQuery.of(context).size.width,
      top: rng.nextDouble() * MediaQuery.of(context).size.height,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)],
        ),
      ).animate(
        onPlay: (c) => c.repeat(reverse: true),
      ).moveY(
        begin: 0,
        end: -20 - rng.nextDouble() * 30,
        duration: Duration(milliseconds: 2000 + rng.nextInt(2000)),
        curve: Curves.easeInOut,
      ).fadeIn(duration: 800.ms),
    );
  }
}
//splash
//sgchghb
//splasnskns
