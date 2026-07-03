import 'package:flutter/material.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: const CustomPaint(painter: GameBoardPainter()),
    );
  }
}
