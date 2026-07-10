import 'package:flutter/material.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';

/// A rounded progress bar used for goal / move tracking.
class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double height;
  final String? label;

  const ProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.success,
    this.height = 16,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
