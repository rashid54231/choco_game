import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/widgets/board/helpers.dart';

/// A decorative variant of [TileWidget] used to highlight special tiles in
/// menus / shop previews with an attention-grabbing glow pulse.
class SpecialTileWidget extends StatelessWidget {
  final Tile tile;
  final double size;

  const SpecialTileWidget({super.key, required this.tile, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3D Mahjong Block Base
          Container(
            margin: const EdgeInsets.only(bottom: 6, right: 3), // Space for 3D depth
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E5), // Ivory/Beige top
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                const BoxShadow(
                  color: Color(0xFFD3B691), // Side edge
                  offset: Offset(3, 3),
                ),
                const BoxShadow(
                  color: Color(0xFFC7A985), // Bottom edge
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(3, 8),
                  blurRadius: 5,
                ),
              ],
              border: Border.all(color: const Color(0xFFE5CCAC), width: 1.5),
            ),
          ),
          // Emoji Icon
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 3),
              child: Text(
                tileEmoji[tile.type ?? TileType.apple] ?? '',
                style: TextStyle(fontSize: size * 0.55),
              ),
            ),
          ),
          // Special Overlays
          if (tile.isSpecial)
            CustomPaint(
              painter: TileShapePainter(
                type: tile.type ?? TileType.apple,
                special: tile.special,
                stripedOrientation: tile.stripedOrientation,
                glow: 1.0,
              ),
              child: const SizedBox.expand(),
            ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: 900.ms,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.08, 1.08),
          curve: Curves.easeInOut,
        );
  }
}
