import 'package:flutter/material.dart';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/widgets/board/helpers.dart';

/// Renders a single board tile with a premium glossy design.
class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool interactive;
  final int row;
  final int col;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.interactive = true,
    this.row = 0,
    this.col = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    
    Widget content;
    if (tile.blocker == BlockerType.chocolate) {
      content = Container(
        width: size, height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.brown[500]!, Colors.brown[800]!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown[900]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(2, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(child: Icon(Icons.apps, color: Colors.brown[900], size: size * 0.5)),
      );
    } else if (tile.ingredient != IngredientType.none) {
      String emoji = tile.ingredient == IngredientType.cherry ? '🍒' : '🌰';
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 6, right: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[200]!, Colors.green[500]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[700]!,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(2, 8),
                  blurRadius: 6,
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 3),
              child: Text(
                emoji,
                style: TextStyle(fontSize: size * 0.55),
              ),
            ),
          ),
        ],
      );
    } else {
      // Base candy colors for gradient mapping
      final Color baseColor = tileBaseColor[tile.type!] ?? Colors.white;
      final Color lightColor = HSLColor.fromColor(baseColor).withLightness(0.7).toColor();
      final Color darkColor = HSLColor.fromColor(baseColor).withLightness(0.4).toColor();

      content = Stack(
        clipBehavior: Clip.none,
        children: [
          // Glossy Candy Base
          Container(
            margin: const EdgeInsets.only(bottom: 6, right: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lightColor,
                  baseColor,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: darkColor,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(2, 8),
                  blurRadius: 6,
                ),
              ],
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            // Inner glossy reflection
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Emoji Icon
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 3),
              child: Text(
                tileEmoji[tile.type!] ?? '',
                style: TextStyle(
                  fontSize: size * 0.55,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(1, 2),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Special Overlays
          if (tile.isSpecial)
            CustomPaint(
              painter: TileShapePainter(
                type: tile.type!,
                special: tile.special,
                stripedOrientation: tile.stripedOrientation,
                glow: 1.0,
              ),
              child: const SizedBox.expand(),
            ),
        ],
      );
      
      if (tile.blocker == BlockerType.ice) {
        content = Stack(
          children: [
            content,
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3 + (tile.iceLayers * 0.15).clamp(0.0, 0.5)),
                border: Border.all(color: Colors.lightBlueAccent.withValues(alpha: 0.8), width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlueAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ],
        );
      }
    }

    return SizedBox(
      width: size,
      height: size,
      child: content,
    );
  }
}
