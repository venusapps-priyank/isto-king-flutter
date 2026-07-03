import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFB86A00));
    canvas.drawCircle(
      center.translate(-radius * 0.08, -radius * 0.08),
      radius * 0.82,
      Paint()..color = RoyalColors.gold,
    );
    canvas.drawCircle(
      center,
      radius * 0.66,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.13
        ..color = const Color(0xFFFFF078),
    );
    const starColor = Color(0xFFFFF6A3);
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius * 0.44 : radius * 0.2;
      final angle = -math.pi / 2 + i * math.pi / 5;
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
    canvas.drawPath(path, Paint()..color = starColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
