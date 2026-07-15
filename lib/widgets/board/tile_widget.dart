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
          color: Colors.brown[700],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown[900]!, width: 2),
        ),
        child: Center(child: Icon(Icons.apps, color: Colors.brown[900], size: size * 0.5)),
      );
    } else {
      content = CustomPaint(
        painter: TileShapePainter(
          type: tile.type!,
          special: tile.special,
          stripedOrientation: tile.stripedOrientation,
          glow: tile.isSpecial ? 1.0 : 0,
        ),
        child: const SizedBox.expand(),
      );
      
      if (tile.blocker == BlockerType.ice) {
        content = Stack(
          children: [
            content,
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4 + (tile.iceLayers * 0.1).clamp(0.0, 0.5)),
                border: Border.all(color: Colors.lightBlueAccent, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      }
    }

    final baseDuration = 3500 + ((row * 100) + (col * 150)) % 1500; // 3.5-5s based on row/col
    final delay = ((row * 150) + (col * 100)).ms; // stagger start

    return SizedBox(
      width: size,
      height: size,
      child: content,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true), delay: delay)
        .move(
          begin: const Offset(0, -5),
          end: const Offset(0, 5),
          duration: baseDuration.ms,
          curve: Curves.easeInOutSine,
        );
  }
}
