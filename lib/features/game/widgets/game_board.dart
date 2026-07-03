import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/token_state.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';
import 'package:isto_king/features/game/widgets/game_token.dart';
import 'package:isto_king/features/game/widgets/path_animated_token.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.tokens,
    required this.movableTokenIds,
    this.movePaths = const {},
    this.onTokenTap,
    super.key,
  });

  static const moveAnimationCurve = Curves.easeInOutCubic;
  static const _millisecondsPerStep = 180;

  final List<TokenState> tokens;
  final Set<int> movableTokenIds;
  final Map<int, List<BoardCell>> movePaths;
  final ValueChanged<int>? onTokenTap;

  static Duration moveAnimationDurationFor(Map<int, List<BoardCell>> movePaths) {
    if (movePaths.isEmpty) return const Duration(milliseconds: 420);

    final longestPath = movePaths.values.fold<int>(
      1,
      (longest, path) => math.max(longest, path.length),
    );
    final segmentCount = math.max(1, longestPath - 1);
    return Duration(
      milliseconds: (segmentCount * _millisecondsPerStep).clamp(360, 1200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final shortest = math.min(size.width, size.height);
          final boardRect = Rect.fromCenter(
            center: size.center(Offset.zero),
            width: shortest,
            height: shortest,
          ).deflate(1);
          final inner = boardRect.deflate(shortest * 0.032);
          final cellSize = inner.width / GameBoardPainter.gridCount;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: GameBoardPainter()),
              ),
              ..._buildTokenWidgets(inner, cellSize),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTokenWidgets(Rect board, double cellSize) {
    final animatingTokenIds = movePaths.keys.toSet();
    final groupedTokens = <BoardCell, List<TokenState>>{};
    for (final token in tokens) {
      if (animatingTokenIds.contains(token.id)) continue;
      groupedTokens.putIfAbsent(_cellForToken(token), () => []).add(token);
    }

    final widgets = <Widget>[];
    for (final entry in groupedTokens.entries) {
      final rect = _cellRect(board, cellSize, entry.key);
      final cellTokens = [...entry.value]
        ..sort((first, second) {
          final firstMovable = movableTokenIds.contains(first.id);
          final secondMovable = movableTokenIds.contains(second.id);
          if (firstMovable == secondMovable) {
            return first.id.compareTo(second.id);
          }
          return firstMovable ? 1 : -1;
        });
      final tokenSize = _tokenSizeFor(cellSize, cellTokens.length);
      final centers = _tokenCenters(rect, cellTokens.length);

      for (var index = 0; index < cellTokens.length; index++) {
        final token = cellTokens[index];
        final center = centers[index];
        widgets.add(
          _positionedToken(
            token: token,
            left: center.dx - tokenSize / 2,
            top: center.dy - tokenSize / 2,
            tokenSize: tokenSize,
          ),
        );
      }
    }

    for (final entry in movePaths.entries) {
      final token = tokens.firstWhere((candidate) => candidate.id == entry.key);
      final tokenSize = cellSize * 0.32;
      widgets.add(
        PathAnimatedToken(
          key: ValueKey('move-${token.id}'),
          waypoints: entry.value,
          board: board,
          cellSize: cellSize,
          tokenSize: tokenSize,
          duration: moveAnimationDurationFor({entry.key: entry.value}),
          curve: moveAnimationCurve,
          child: GameToken(
            color: gamePlayers[token.playerIndex].color,
            size: tokenSize,
            isMovable: false,
            semanticLabel:
                '${gamePlayers[token.playerIndex].name} token ${token.tokenIndex + 1}',
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _positionedToken({
    required TokenState token,
    required double left,
    required double top,
    required double tokenSize,
  }) {
    final isMovable = movableTokenIds.contains(token.id);
    return Positioned(
      key: ValueKey(token.id),
      left: left,
      top: top,
      width: tokenSize,
      height: tokenSize,
      child: GameToken(
        color: gamePlayers[token.playerIndex].color,
        size: tokenSize,
        isMovable: isMovable,
        semanticLabel:
            '${gamePlayers[token.playerIndex].name} token ${token.tokenIndex + 1}',
        onTap: () => onTokenTap?.call(token.id),
      ),
    );
  }

  BoardCell _cellForToken(TokenState token) {
    if (token.isFinished) return IstoBoardPaths.centerCell;
    if (token.isAtStart) {
      return IstoBoardPaths.homeCellForPlayer(token.playerIndex);
    }
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    if (token.pathIndex < 0 || token.pathIndex >= path.length) {
      return IstoBoardPaths.homeCellForPlayer(token.playerIndex);
    }
    return path[token.pathIndex];
  }

  Rect _cellRect(Rect board, double cellSize, BoardCell cell) {
    return Rect.fromLTWH(
      board.left + cell.col * cellSize,
      board.top + cell.row * cellSize,
      cellSize,
      cellSize,
    );
  }

  double _tokenSizeFor(double cellSize, int count) {
    if (count <= 4) return cellSize * 0.32;
    if (count <= 9) return cellSize * 0.25;
    return cellSize * 0.2;
  }

  List<Offset> _tokenCenters(Rect rect, int count) {
    if (count == 1) return [rect.center];

    final spread = rect.width * 0.28;
    if (count == 2) {
      return [
        rect.center.translate(-spread, 0),
        rect.center.translate(spread, 0),
      ];
    }
    if (count == 3) {
      return [
        rect.center.translate(0, -spread),
        rect.center.translate(-spread, spread * 0.75),
        rect.center.translate(spread, spread * 0.75),
      ];
    }
    if (count == 4) {
      return [
        rect.center.translate(-spread, 0),
        rect.center.translate(0, -spread),
        rect.center.translate(0, spread),
        rect.center.translate(spread, 0),
      ];
    }

    final columns = count <= 6 ? 3 : 4;
    final rows = (count / columns).ceil();
    final horizontalGap = rect.width * 0.55 / math.max(1, columns - 1);
    final verticalGap = rect.height * 0.55 / math.max(1, rows - 1);

    return [
      for (var index = 0; index < count; index++)
        rect.center.translate(
          (index % columns - (columns - 1) / 2) * horizontalGap,
          (index ~/ columns - (rows - 1) / 2) * verticalGap,
        ),
    ];
  }
}
