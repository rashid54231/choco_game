import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';

/// Paints glossy, 3D candy-style tiles inspired by the reference design.
/// Each tile type has a unique shape: sphere, cube, flower, bean, berry, star.
class TileShapePainter extends CustomPainter {
  final TileType type;
  final SpecialKind special;
  final StripedOrientation? stripedOrientation;
  final double glow;
  final double scale;

  TileShapePainter({
    required this.type,
    this.special = SpecialKind.none,
    this.stripedOrientation,
    this.glow = 0,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    _drawSpecialOverlay(canvas, size, center, radius);
  }

  // Tile body methods removed in favor of Mahjong 3D block rendering

  /// Overlay indicators for special tiles — bigger, bolder, with glow ring.
  void _drawSpecialOverlay(Canvas canvas, Size size, Offset c, double r) {
    if (special == SpecialKind.none) return;

    // Outer glow ring
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(c, r + 3, glowPaint);

    // Pulsing ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.4 + glow * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(c, r + 2, ringPaint);

    final overlayPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (special) {
      case SpecialKind.striped:
        if (stripedOrientation == StripedOrientation.horizontal) {
          for (double dy = -r * 0.5; dy <= r * 0.5; dy += r * 0.35) {
            canvas.drawLine(
              Offset(c.dx - r * 0.7, c.dy + dy),
              Offset(c.dx + r * 0.7, c.dy + dy),
              overlayPaint,
            );
          }
          // Arrow hints
          final arrowPaint = Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawLine(Offset(c.dx - r * 0.9, c.dy), Offset(c.dx - r * 0.7, c.dy - r * 0.15), arrowPaint);
          canvas.drawLine(Offset(c.dx - r * 0.9, c.dy), Offset(c.dx - r * 0.7, c.dy + r * 0.15), arrowPaint);
          canvas.drawLine(Offset(c.dx + r * 0.9, c.dy), Offset(c.dx + r * 0.7, c.dy - r * 0.15), arrowPaint);
          canvas.drawLine(Offset(c.dx + r * 0.9, c.dy), Offset(c.dx + r * 0.7, c.dy + r * 0.15), arrowPaint);
        } else {
          for (double dx = -r * 0.5; dx <= r * 0.5; dx += r * 0.35) {
            canvas.drawLine(
              Offset(c.dx + dx, c.dy - r * 0.7),
              Offset(c.dx + dx, c.dy + r * 0.7),
              overlayPaint,
            );
          }
          // Arrow hints
          final arrowPaint = Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawLine(Offset(c.dx, c.dy - r * 0.9), Offset(c.dx - r * 0.15, c.dy - r * 0.7), arrowPaint);
          canvas.drawLine(Offset(c.dx, c.dy - r * 0.9), Offset(c.dx + r * 0.15, c.dy - r * 0.7), arrowPaint);
          canvas.drawLine(Offset(c.dx, c.dy + r * 0.9), Offset(c.dx - r * 0.15, c.dy + r * 0.7), arrowPaint);
          canvas.drawLine(Offset(c.dx, c.dy + r * 0.9), Offset(c.dx + r * 0.15, c.dy + r * 0.7), arrowPaint);
        }
        break;

      case SpecialKind.wrapped:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: c, width: r * 1.5, height: r * 1.5),
            Radius.circular(r * 0.3),
          ),
          overlayPaint,
        );
        // Inner diamond
        final diamond = Path()
          ..moveTo(c.dx, c.dy - r * 0.5)
          ..lineTo(c.dx + r * 0.5, c.dy)
          ..lineTo(c.dx, c.dy + r * 0.5)
          ..lineTo(c.dx - r * 0.5, c.dy)
          ..close();
        canvas.drawPath(diamond, Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
        break;

      case SpecialKind.colorBomb:
        canvas.drawCircle(c, r * 0.9, overlayPaint);
        // Rainbow dots — bigger, with glow
        final colors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple, Colors.orange];
        for (int i = 0; i < colors.length; i++) {
          final a = (i * 2 * math.pi) / colors.length - math.pi / 2;
          final p = Offset(c.dx + math.cos(a) * r * 0.6, c.dy + math.sin(a) * r * 0.6);
          // Glow behind dot
          canvas.drawCircle(p, 6, Paint()..color = colors[i].withOpacity(0.3));
          canvas.drawCircle(p, 4, Paint()..color = colors[i]);
        }
        break;

      case SpecialKind.none:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant TileShapePainter old) =>
      old.type != type || old.special != special || old.glow != glow;
}
