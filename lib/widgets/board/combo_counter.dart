import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Floating combo counter that appears during cascading matches.
/// Shows "x2", "x3", etc. centered on the board.
class ComboCounter extends StatelessWidget {
  final int combo;
  final bool show;

  const ComboCounter({
    super.key,
    required this.combo,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    if (!show || combo < 2) return const SizedBox.shrink();

    final color = combo >= 5
        ? const Color(0xFFFF1744)
        : combo >= 3
            ? const Color(0xFFFF9100)
            : const Color(0xFFFFD600);

    return Center(
      child: Text(
        'x$combo',
        key: ValueKey('combo_$combo'),
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: color,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3)),
            Shadow(color: color.withOpacity(0.6), blurRadius: 16),
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: 200.ms,
            curve: Curves.elasticOut,
          )
          .then(delay: 600.ms)
          .fade(begin: 1.0, end: 0.0, duration: 300.ms),
    );
  }
}
