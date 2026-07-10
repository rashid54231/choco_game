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
      child: CustomPaint(
        painter: TileShapePainter(
          type: tile.type ?? TileType.redBerry,
          special: tile.special,
          stripedOrientation: tile.stripedOrientation,
          glow: 1,
        ),
        child: const SizedBox.expand(),
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
