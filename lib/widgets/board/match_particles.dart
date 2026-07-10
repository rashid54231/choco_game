import 'dart:math';
import 'package:flutter/material.dart';

/// A single particle in the explosion.
class _Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  double size;
  Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
  });

  double get progress => 1.0 - (life / maxLife);
  bool get isDead => life <= 0;
}

/// Lightweight particle burst for match effects.
/// Renders 8-12 colored circles that fly outward and fade.
class MatchParticles extends StatefulWidget {
  final Offset center;
  final Color color;
  final VoidCallback? onComplete;

  const MatchParticles({
    super.key,
    required this.center,
    required this.color,
    this.onComplete,
  });

  @override
  State<MatchParticles> createState() => _MatchParticlesState();
}

class _MatchParticlesState extends State<MatchParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _generateParticles();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    _controller.forward();
  }

  void _generateParticles() {
    final count = 8 + _rng.nextInt(5);
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count + _rng.nextDouble() * 0.3;
      final speed = 60.0 + _rng.nextDouble() * 80.0;
      _particles.add(_Particle(
        position: widget.center,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed),
        life: 0.35 + _rng.nextDouble() * 0.15,
        maxLife: 0.35 + _rng.nextDouble() * 0.15,
        size: 4.0 + _rng.nextDouble() * 6.0,
        color: _tintColor(),
      ));
    }
  }

  Color _tintColor() {
    final hsl = HSLColor.fromColor(widget.color);
    final lightened = hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0));
    return lightened.toColor();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dt = 0.016; // ~60fps
        for (final p in _particles) {
          p.life -= dt;
          p.position += p.velocity * dt;
          p.velocity += Offset(0, 120) * dt; // gravity
        }
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(particles: _particles),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.isDead) continue;
      final opacity = (1.0 - p.progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      final radius = p.size * (1.0 - p.progress * 0.5);
      canvas.drawCircle(p.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
