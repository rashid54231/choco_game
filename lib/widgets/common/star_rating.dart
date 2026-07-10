import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';

/// A row of 3 star icons that can pop in one-by-one based on [count].
class StarRating extends StatelessWidget {
  final int count; // 0..3
  final double size;

  const StarRating({super.key, required this.count, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < count;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? AppColors.starFilled : AppColors.starEmpty,
        )
            .animate(delay: (i * 250).ms)
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .shake(hz: 3, duration: 300.ms);
      }),
    );
  }
}
