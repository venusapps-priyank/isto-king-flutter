import 'package:flutter/material.dart';
import 'package:isto_king/features/game/painters/coin_painter.dart';

class CoinIcon extends StatelessWidget {
  const CoinIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: CoinPainter()),
    );
  }
}
