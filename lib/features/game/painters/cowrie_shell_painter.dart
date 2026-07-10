import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';

class CowrieShellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shell = Path()
      ..moveTo(rect.width * 0.18, rect.height * 0.78)
      ..cubicTo(
        rect.width * 0.02,
        rect.height * 0.38,
        rect.width * 0.33,
        rect.height * 0.02,
        rect.width * 0.64,
        rect.height * 0.08,
      )
      ..cubicTo(
        rect.width * 0.98,
        rect.height * 0.15,
        rect.width * 0.98,
        rect.height * 0.66,
        rect.width * 0.62,
        rect.height * 0.9,
      )
      ..cubicTo(
        rect.width * 0.45,
        rect.height,
        rect.width * 0.25,
        rect.height * 0.96,
        rect.width * 0.18,
        rect.height * 0.78,
      )
      ..close();
    canvas.drawShadow(shell, Colors.black, 2, true);
    canvas.drawPath(shell, Paint()..color = const Color(0xFFFFF4D7));
    final slit = Paint()
      ..color = RoyalColors.brown
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.2),
      Offset(size.width * 0.36, size.height * 0.82),
      slit,
    );
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.28 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.5, y),
        Offset(size.width * 0.61, y + size.height * 0.04),
        Paint()
          ..color = RoyalColors.brown.withValues(alpha: 0.65)
          ..strokeWidth = size.width * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
