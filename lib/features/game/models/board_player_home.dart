import 'package:flutter/material.dart';

class BoardPlayerHome {
  const BoardPlayerHome({
    required this.playerIndex,
    required this.col,
    required this.row,
    required this.color,
    required this.arrowAngle,
    int? arrowCol,
    int? arrowRow,
  }) : arrowCol = arrowCol ?? col - 1,
       arrowRow = arrowRow ?? row;

  final int playerIndex;
  final int col;
  final int row;
  final Color color;
  final double arrowAngle;
  final int arrowCol;
  final int arrowRow;
}
