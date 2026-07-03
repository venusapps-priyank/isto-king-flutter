import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class GameToken extends StatelessWidget {
  const GameToken({
    required this.color,
    required this.size,
    required this.isMovable,
    required this.semanticLabel,
    this.onTap,
    super.key,
  });

  final Color color;
  final double size;
  final bool isMovable;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: isMovable,
      enabled: isMovable,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isMovable ? onTap : null,
        child: AnimatedScale(
          scale: isMovable ? 1.12 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _GameTokenPainter(color: color, isMovable: isMovable),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameTokenPainter extends CustomPainter {
  const _GameTokenPainter({required this.color, required this.isMovable});

  final Color color;
  final bool isMovable;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    if (isMovable) {
      canvas.drawCircle(
        center,
        radius * 0.98,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.16
          ..color = RoyalColors.gold,
      );
      canvas.drawCircle(
        center,
        radius * 0.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.08
          ..color = RoyalColors.parchmentLight,
      );
    }

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.82)),
      Colors.black,
      2,
      true,
    );
    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()..color = Color.lerp(color, Colors.black, 0.16)!,
    );
    canvas.drawCircle(
      center.translate(-radius * 0.12, -radius * 0.12),
      radius * 0.64,
      Paint()..color = color,
    );
    canvas.drawCircle(
      center,
      radius * 0.62,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.14
        ..color = Colors.white,
    );
    _drawStar(canvas, center, radius * 0.4);
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final pointRadius = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * pointRadius,
        center.dy + math.sin(angle) * pointRadius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GameTokenPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isMovable != isMovable;
  }
}
