import 'dart:math' as math;
import 'package:flutter/material.dart';

class HexPatternPainter extends CustomPainter {
  HexPatternPainter({this.color = Colors.white, this.opacity = 0.07});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const cellW = 30.0;
    const cellH = 34.0;

    final cols = (size.width / cellW).ceil() + 1;
    final rows = (size.height / cellH).ceil() + 1;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final cx = col * cellW + (row.isOdd ? cellW / 2 : 0);
        final cy = row * cellH;
        _drawHex(canvas, paint, cx, cy, cellW, cellH);
      }
    }
  }

  void _drawHex(
      Canvas canvas, Paint paint, double cx, double cy, double w, double h) {
    final r = w / 2;
    final hr = h / 2;
    final path = Path()
      ..moveTo(cx + r, cy)
      ..lineTo(cx + w, cy + hr * 0.5)
      ..lineTo(cx + w, cy + hr * 1.5)
      ..lineTo(cx + r, cy + h)
      ..lineTo(cx, cy + hr * 1.5)
      ..lineTo(cx, cy + hr * 0.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HexPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}

class HexPattern extends StatelessWidget {
  const HexPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.07,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexPatternPainter(color: color, opacity: opacity),
      child: const SizedBox.expand(),
    );
  }
}

// Ignore unused import warning
// ignore: unused_element
final _mathPi = math.pi;
