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
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 100.ms)
          .moveY(begin: 0, end: -40, duration: 700.ms, curve: Curves.easeOut)
          .fade(begin: 1.0, end: 0.0, duration: 700.ms),
    );
  }
}
