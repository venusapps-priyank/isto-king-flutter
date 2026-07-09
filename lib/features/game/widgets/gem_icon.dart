import 'package:flutter/material.dart';
import 'package:isto_king/features/game/painters/gem_painter.dart';

class GemIcon extends StatelessWidget {
  const GemIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: GemPainter()),
    );
  }
}
