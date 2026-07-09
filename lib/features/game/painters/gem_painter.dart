import 'dart:math' as math;

import 'package:flutter/material.dart';

class GemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final path = Path();
    const facets = 6;
    for (var i = 0; i < facets; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / facets;
      final r = i.isEven ? radius * 0.92 : radius * 0.55;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB388FF), Color(0xFF7B1FA2), Color(0xFF4A148C)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.08
        ..color = const Color(0xFFE1BEE7),
    );

    canvas.drawCircle(
      center.translate(-radius * 0.15, -radius * 0.2),
      radius * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
