import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class ScreenOrnamentPainter extends CustomPainter {
  const ScreenOrnamentPainter({
    this.topInset = 0,
    this.topCornerScale = 1.0,
    this.bottomCornerScale = 1.18,
    this.bottomConnectorHeight = 0,
  });

  final double topInset;
  final double topCornerScale;
  final double bottomCornerScale;
  final double bottomConnectorHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = RoyalColors.outerRed;
    final topEdge = topInset.clamp(0.0, size.height);
    if (bottomConnectorHeight > 0) {
      canvas.drawRect(
        Rect.fromLTWH(
          0,
          size.height - bottomConnectorHeight,
          size.width,
          bottomConnectorHeight,
        ),
        red,
      );
    }
    for (final corner in [
      Offset(0, topEdge),
      Offset(size.width, topEdge),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      final sx = corner.dx == 0 ? 1.0 : -1.0;
      final isTopCorner = corner.dy == topEdge;
      final sy = isTopCorner ? 1.0 : -1.0;
      final scale = corner.dy == size.height
          ? bottomCornerScale
          : isTopCorner
          ? topCornerScale
          : 1.0;
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.scale(sx * scale, sy * scale);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(96, 0)
        ..cubicTo(74, 3, 65, 15, 61, 31)
        ..cubicTo(55, 52, 39, 63, 20, 64)
        ..cubicTo(9, 65, 2, 74, 0, 88)
        ..close();
      canvas.drawPath(path, red);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ScreenOrnamentPainter oldDelegate) {
    return oldDelegate.topInset != topInset ||
        oldDelegate.topCornerScale != topCornerScale ||
        oldDelegate.bottomCornerScale != bottomCornerScale ||
        oldDelegate.bottomConnectorHeight != bottomConnectorHeight;
  }
}
