import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Dramatic bomb blast animation — radial shockwave + particle burst + line beams.
class BombBlastOverlay extends StatefulWidget {
  final Offset center;
  final Color color;
  final Set<Offset> hitPositions;
  final VoidCallback? onComplete;

  const BombBlastOverlay({
    super.key,
    required this.center,
    required this.color,
    required this.hitPositions,
    this.onComplete,
  });

  @override
  State<BombBlastOverlay> createState() => _BombBlastOverlayState();
}

class _BombBlastOverlayState extends State<BombBlastOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _shockwaveCtrl;
  late final AnimationController _particlesCtrl;
  late final AnimationController _beamCtrl;
  late final AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _shockwaveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _particlesCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _beamCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _flashCtrl.forward().then((_) {
      _shockwaveCtrl.forward();
      _beamCtrl.forward();
      _particlesCtrl.forward().then((_) {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    _shockwaveCtrl.dispose();
    _particlesCtrl.dispose();
    _beamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flashCtrl, _shockwaveCtrl, _particlesCtrl, _beamCtrl]),
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _BombBlastPainter(
            center: widget.center,
            color: widget.color,
            hitPositions: widget.hitPositions,
            flashProgress: _flashCtrl.value,
            shockwaveProgress: _shockwaveCtrl.value,
            particlesProgress: _particlesCtrl.value,
            beamProgress: _beamCtrl.value,
          ),
        );
      },
    );
  }
}

class _BombBlastPainter extends CustomPainter {
  final Offset center;
  final Color color;
  final Set<Offset> hitPositions;
  final double flashProgress;
  final double shockwaveProgress;
  final double particlesProgress;
  final double beamProgress;
  final math.Random _rng = math.Random(42);

  _BombBlastPainter({
    required this.center,
    required this.color,
    required this.hitPositions,
    required this.flashProgress,
    required this.shockwaveProgress,
    required this.particlesProgress,
    required this.beamProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) White flash
    if (flashProgress < 1.0) {
      final flashOpacity = (1.0 - flashProgress) * 0.6;
      canvas.drawCircle(center, 30 + flashProgress * 20,
          Paint()..color = Colors.white.withOpacity(flashOpacity));
    }

    // 2) Shockwave ring
    if (shockwaveProgress > 0 && shockwaveProgress < 1.0) {
      final radius = shockwaveProgress * 200;
      final opacity = (1.0 - shockwaveProgress) * 0.8;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0 * (1.0 - shockwaveProgress),
      );
      // Second ring
      canvas.drawCircle(
        center,
        radius * 0.7,
        Paint()
          ..color = Colors.white.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * (1.0 - shockwaveProgress),
      );
    }

    // 3) Beam lines toward hit positions
    if (beamProgress > 0) {
      final beamPaint = Paint()
        ..strokeWidth = 3.0 * (1.0 - beamProgress)
        ..strokeCap = StrokeCap.round;

      for (final pos in hitPositions) {
        final opacity = (1.0 - beamProgress) * 0.7;
        beamPaint.color = color.withOpacity(opacity);

        // Beam from center to target
        final dir = pos - center;
        final dist = dir.distance;
        final norm = dir / dist;
        final beamEnd = center + norm * dist * beamProgress.clamp(0.0, 1.0);

        canvas.drawLine(center, beamEnd, beamPaint);

        // Glow on beam
        beamPaint
          ..color = Colors.white.withOpacity(opacity * 0.3)
          ..strokeWidth = 8.0 * (1.0 - beamProgress);
        canvas.drawLine(center, beamEnd, beamPaint);
        beamPaint.strokeWidth = 3.0 * (1.0 - beamProgress);
      }
    }

    // 4) Particle burst
    if (particlesProgress > 0 && particlesProgress < 1.0) {
      final particleCount = 24;
      for (int i = 0; i < particleCount; i++) {
        final angle = (2 * math.pi * i) / particleCount + _rng.nextDouble() * 0.3;
        final speed = 80.0 + _rng.nextDouble() * 120.0;
        final dx = math.cos(angle) * speed * particlesProgress;
        final dy = math.sin(angle) * speed * particlesProgress - 60 * particlesProgress; // gravity
        final pos = center + Offset(dx, dy);
        final opacity = (1.0 - particlesProgress) * 0.9;
        final pSize = (4.0 + _rng.nextDouble() * 5.0) * (1.0 - particlesProgress * 0.5);

        // Glow
        canvas.drawCircle(pos, pSize + 3,
            Paint()..color = color.withOpacity(opacity * 0.3));
        // Core
        canvas.drawCircle(pos, pSize,
            Paint()..color = _tintParticle(i).withOpacity(opacity));
      }
    }

    // 5) Impact dots at hit positions
    if (beamProgress > 0.5) {
      final impactOpacity = ((beamProgress - 0.5) * 2) * 0.8;
      for (final pos in hitPositions) {
        canvas.drawCircle(pos, 8 * impactOpacity,
            Paint()..color = Colors.white.withOpacity(impactOpacity * 0.5));
        canvas.drawCircle(pos, 4 * impactOpacity,
            Paint()..color = color.withOpacity(impactOpacity));
      }
    }
  }

  Color _tintParticle(int index) {
    final colors = [
      color,
      Colors.white,
      color.withOpacity(0.7),
      const Color(0xFFFFD54F),
      const Color(0xFFFF6B9D),
    ];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(_BombBlastPainter oldDelegate) => true;
}
