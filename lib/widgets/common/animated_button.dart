import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';

/// Sleek, modern animated button for the candy game.
class AnimatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final LinearGradient? gradient;
  final Color textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enabled;
  final double borderRadius;
  final bool animate;

  const AnimatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.gradient,
    this.textColor = AppColors.textWhite,
    this.width,
    this.height = 52,
    this.icon,
    this.enabled = true,
    this.borderRadius = 16,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: enabled
          ? () {
              AudioService.instance.playButton();
              onPressed();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? (gradient == null ? color : null) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: (gradient != null ? AppColors.primary : color).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: enabled ? textColor : Colors.white38),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Baloo2',
                fontSize: width != null && width! < 120 ? 14 : 17,
                fontWeight: FontWeight.w700,
                color: enabled ? textColor : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );

    if (!animate) return button;

    return button
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: 1200.ms,
          begin: const Offset(1, 1),
          end: const Offset(1.03, 1.03),
          curve: Curves.easeInOut,
        );
  }
}
