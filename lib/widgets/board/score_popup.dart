import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Floating score text that rises and fades at the location of a match.
class ScorePopup extends StatelessWidget {
  final int score;
  final Offset position;

  const ScorePopup({
    super.key,
    required this.score,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Text(
        '+$score',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          fontFamily: 'Baloo2',
          shadows: [
            Shadow(color: Color(0x88FF6B9D), blurRadius: 8, offset: Offset(0, 4)),
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 400.ms, curve: Curves.elasticOut)
          .moveY(begin: 0, end: -50, duration: 800.ms, curve: Curves.easeOutCubic)
          .fade(begin: 1.0, end: 0.0, delay: 500.ms, duration: 300.ms),
    );
  }
}
