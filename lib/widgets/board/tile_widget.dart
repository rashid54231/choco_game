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

    final isSpecial = tile.isSpecial;
    return SizedBox(
      width: size,
      height: size,
      child: content,
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
