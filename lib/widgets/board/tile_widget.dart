import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/widgets/board/helpers.dart';

/// Renders a single board tile with a subtle idle bounce and squash/stretch
/// support. Used by the [GameBoard].
class TileWidget extends StatelessWidget {
  final Tile tile;
  final double size;
  final bool interactive;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.isEmpty) {
      return SizedBox(width: size, height: size);
    }
    final isSpecial = tile.isSpecial;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TileShapePainter(
          type: tile.type!,
          special: tile.special,
          stripedOrientation: tile.stripedOrientation,
          glow: isSpecial ? 1.0 : 0,
        ),
        child: const SizedBox.expand(),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          duration: isSpecial ? 800.ms : 1500.ms,
          begin: const Offset(0.97, 0.97),
          end: isSpecial ? const Offset(1.08, 1.08) : const Offset(1.0, 1.0),
          curve: Curves.easeInOut,
        );
  }
}
