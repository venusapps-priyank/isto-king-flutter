import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/game/models/board_player_home.dart';

class GameBoardPainter extends CustomPainter {
  const GameBoardPainter({
    this.innerPathAccess = const [false, false, false, false],
  });

  static const int gridCount = 5;
  static const playerHomes = [
    BoardPlayerHome(
      playerIndex: 0,
      col: 2,
      row: 0,
      color: RoyalColors.red,
      arrowAngle: math.pi / 2,
      arrowCol: 3,
    ),
    BoardPlayerHome(
      playerIndex: 3,
      col: 2,
      row: 4,
      color: RoyalColors.blue,
      arrowAngle: -math.pi / 2,
    ),
    BoardPlayerHome(
      playerIndex: 2,
      col: 0,
      row: 2,
      color: RoyalColors.yellow,
      arrowAngle: 0,
      arrowCol: 0,
      arrowRow: 1,
    ),
    BoardPlayerHome(
      playerIndex: 1,
      col: 4,
      row: 2,
      color: RoyalColors.green,
      arrowAngle: math.pi,
      arrowCol: 4,
      arrowRow: 3,
    ),
  ];

  final List<bool> innerPathAccess;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final boardRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: shortest,
      height: shortest,
    ).deflate(1);
    final borderWidth = math.max(4.0, shortest * 0.018);
    final outer = RRect.fromRectAndRadius(
      boardRect.deflate(borderWidth / 2),
      const Radius.circular(19),
    );
    final inner = boardRect.deflate(shortest * 0.032);
    final innerRRect = RRect.fromRectAndRadius(
      inner,
      const Radius.circular(12),
    );
    final cell = inner.width / gridCount;

    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = RoyalColors.darkRed,
    );
    canvas.drawRRect(innerRRect, Paint()..color = RoyalColors.boardCell);

    for (final home in playerHomes) {
      _drawPlayerHomeCell(
        canvas,
        _cellRect(inner, cell, home.col, home.row),
        home.color,
      );
    }

    _drawGrid(canvas, inner, innerRRect, cell);
    _drawCenterHome(canvas, _cellRect(inner, cell, 2, 2));

    for (final home in playerHomes) {
      _drawCrossLines(canvas, _cellRect(inner, cell, home.col, home.row));
    }

    for (final home in playerHomes) {
      final isArrowEnabled =
          home.playerIndex < innerPathAccess.length &&
          innerPathAccess[home.playerIndex];
      _drawArrow(
        canvas,
        _cellRect(inner, cell, home.arrowCol, home.arrowRow),
        home.color,
        home.arrowAngle,
        isEnabled: isArrowEnabled,
      );
    }
  }

  Rect _cellRect(Rect board, double cell, int col, int row) {
    return Rect.fromLTWH(
      board.left + col * cell,
      board.top + row * cell,
      cell,
      cell,
    );
  }

  void _drawPlayerHomeCell(Canvas canvas, Rect rect, Color color) {
    canvas.drawRect(rect, Paint()..color = color);
  }

  void _drawGrid(Canvas canvas, Rect board, RRect border, double cell) {
    final line = Paint()
      ..color = RoyalColors.brown
      ..strokeWidth = math.max(1.0, cell * 0.035);
    for (var i = 1; i < gridCount; i++) {
      final offset = board.left + i * cell;
      canvas.drawLine(
        Offset(offset, board.top),
        Offset(offset, board.bottom),
        line,
      );
      final y = board.top + i * cell;
      canvas.drawLine(Offset(board.left, y), Offset(board.right, y), line);
    }
    canvas.drawRRect(border, line..style = PaintingStyle.stroke);
  }

  void _drawCenterHome(Canvas canvas, Rect rect) {
    final center = rect.center;
    final colors = [
      RoyalColors.red,
      RoyalColors.green,
      RoyalColors.blue,
      RoyalColors.yellow,
    ];
    final points = [
      [rect.topLeft, rect.topRight, center],
      [rect.topRight, rect.bottomRight, center],
      [rect.bottomRight, rect.bottomLeft, center],
      [rect.bottomLeft, rect.topLeft, center],
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(points[i][0].dx, points[i][0].dy)
          ..lineTo(points[i][1].dx, points[i][1].dy)
          ..lineTo(points[i][2].dx, points[i][2].dy)
          ..close(),
        Paint()..color = colors[i],
      );
    }
    _drawCrossLines(canvas, rect);
  }

  void _drawCrossLines(Canvas canvas, Rect rect) {
    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(1.5, rect.width * 0.035)
      ..strokeCap = StrokeCap.butt;
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawLine(rect.topLeft, rect.bottomRight, cross);
    canvas.drawLine(rect.topRight, rect.bottomLeft, cross);
    canvas.restore();
  }

  void _drawArrow(
    Canvas canvas,
    Rect rect,
    Color color,
    double angle, {
    required bool isEnabled,
  }) {
    final fillColor = isEnabled
        ? color
        : Color.lerp(color, RoyalColors.boardCell, 0.72)!;
    final outlineColor = isEnabled
        ? Colors.white.withValues(alpha: 0.75)
        : RoyalColors.brown.withValues(alpha: 0.38);
    final tipDir = Offset(math.cos(angle), math.sin(angle));
    final length = rect.width * 0.85;
    final tipX = length * 0.35;
    final tailX = length * 0.65;
    final arrowMidX = (tipX - tailX) / 2;
    final boundary =
        rect.center +
        Offset(tipDir.dx * rect.width / 2, tipDir.dy * rect.height / 2);
    canvas.save();
    canvas.translate(
      boundary.dx - tipDir.dx * arrowMidX,
      boundary.dy - tipDir.dy * arrowMidX,
    );
    canvas.rotate(angle);
    final shadowPath = Path()
      ..moveTo(tipX, 0)
      ..lineTo(length * 0.02, -length * 0.20)
      ..lineTo(length * 0.08, -length * 0.075)
      ..lineTo(-tailX, -length * 0.075)
      ..lineTo(-tailX, length * 0.075)
      ..lineTo(length * 0.08, length * 0.075)
      ..lineTo(length * 0.02, length * 0.20)
      ..close();
    if (isEnabled) {
      canvas.drawShadow(shadowPath, Colors.black, 2, true);
    }
    final path = Path()
      ..moveTo(tipX, 0)
      ..lineTo(length * 0.02, -length * 0.20)
      ..lineTo(length * 0.08, -length * 0.075)
      ..lineTo(-tailX, -length * 0.075)
      ..lineTo(-tailX, length * 0.075)
      ..lineTo(length * 0.08, length * 0.075)
      ..lineTo(length * 0.02, length * 0.20)
      ..close();
    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, rect.width * 0.024)
        ..strokeJoin = StrokeJoin.round
        ..color = outlineColor,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    return !listEquals(oldDelegate.innerPathAccess, innerPathAccess);
  }
}
