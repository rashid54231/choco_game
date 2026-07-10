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

    // Drop shadow beneath every tile.
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(0, 3), width: radius * 2, height: radius * 1.6),
      shadowPaint,
    );

    // Glow behind special tiles.
    if (special != SpecialKind.none) {
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3 + glow * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 12 + glow * 6);
      canvas.drawCircle(center, radius + 4, glowPaint);
    }

    _drawTileBody(canvas, size, center, radius);
    _drawHighlight(canvas, size, center, radius);
    _drawSpecialOverlay(canvas, size, center, radius);
  }

  void _drawTileBody(Canvas canvas, Size size, Offset center, double r) {
    final base = tileBaseColor[type]!;
    final accent = tileAccentColor[type]!;

    switch (type) {
      case TileType.blueSphere:
        _drawSphere(canvas, center, r, base, accent);
        break;
      case TileType.greenSquare:
        _drawSquare(canvas, center, r, base, accent);
        break;
      case TileType.purpleFlower:
        _drawFlower(canvas, center, r, base, accent);
        break;
      case TileType.orangeBean:
        _drawBean(canvas, center, r, base, accent);
        break;
      case TileType.redBerry:
        _drawBerry(canvas, center, r, base, accent);
        break;
      case TileType.yellowStar:
        _drawStar(canvas, center, r, base, accent);
        break;
    }
  }

  /// Glossy sphere — radial gradient circle.
  void _drawSphere(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final rect = Rect.fromCircle(center: c, radius: r);
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.1,
      colors: [tileHighlightColor[TileType.blueSphere]!, base, accent],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(c, r, Paint()..shader = gradient.createShader(rect));
    // Outline
    canvas.drawCircle(c, r, Paint()
      ..color = accent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  /// Rounded square / pillow shape.
  void _drawSquare(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: r * 1.7, height: r * 1.7),
      Radius.circular(r * 0.35),
    );
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [tileHighlightColor[TileType.greenSquare]!, base, accent],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(rect.outerRect);
    canvas.drawRRect(rect, Paint()..shader = shader);
    // Outline
    canvas.drawRRect(rect, Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  /// Six-petal flower shape.
  void _drawFlower(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final petalCenter = Offset(c.dx + math.cos(angle) * r * 0.45, c.dy + math.sin(angle) * r * 0.45);
      path.addOval(Rect.fromCircle(center: petalCenter, radius: r * 0.52));
    }
    final shader = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      colors: [tileHighlightColor[TileType.purpleFlower]!, base, accent],
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawPath(path, Paint()..shader = shader);
    // Center circle
    canvas.drawCircle(c, r * 0.25, Paint()..color = accent);
  }

  /// Oval bean / capsule shape.
  void _drawBean(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: r * 2.1, height: r * 1.5),
      Radius.circular(r * 0.75),
    );
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [tileHighlightColor[TileType.orangeBean]!, base, accent],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(rect.outerRect);
    canvas.drawRRect(rect, Paint()..shader = shader);
    canvas.drawRRect(rect, Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  /// Cluster of small berries.
  void _drawBerry(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final offsets = [
      Offset(c.dx, c.dy - r * 0.35),
      Offset(c.dx - r * 0.4, c.dy + r * 0.2),
      Offset(c.dx + r * 0.4, c.dy + r * 0.2),
      Offset(c.dx, c.dy + r * 0.45),
    ];
    final berryR = r * 0.4;
    for (final off in offsets) {
      final rect = Rect.fromCircle(center: off, radius: berryR);
      final shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [tileHighlightColor[TileType.redBerry]!, base, accent],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
      canvas.drawCircle(off, berryR, Paint()..shader = shader);
      canvas.drawCircle(off, berryR, Paint()
        ..color = accent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
  }

  /// Five-pointed star.
  void _drawStar(Canvas canvas, Offset c, double r, Color base, Color accent) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final ang = (i * math.pi / 5) - math.pi / 2;
      final rad = i.isEven ? r * 1.0 : r * 0.48;
      final p = Offset(c.dx + rad * math.cos(ang), c.dy + rad * math.sin(ang));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    final shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [tileHighlightColor[TileType.yellowStar]!, base, accent],
      stops: const [0.0, 0.4, 1.0],
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawPath(path, Paint()..shader = shader);
    canvas.drawPath(path, Paint()
      ..color = accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  /// Glossy highlight sheen — white oval near the top of each tile.
  void _drawHighlight(Canvas canvas, Size size, Offset c, double r) {
    final sheenPaint = Paint()..color = Colors.white.withOpacity(0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - r * 0.1, c.dy - r * 0.35),
        width: r * 1.0,
        height: r * 0.45,
      ),
      sheenPaint,
    );
    // Small dot highlight.
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.7);
    canvas.drawCircle(Offset(c.dx - r * 0.15, c.dy - r * 0.3), r * 0.12, dotPaint);
  }

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
