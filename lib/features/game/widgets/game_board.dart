import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/logic/move_animation_timing.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/token_state.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';
import 'package:isto_king/features/game/widgets/game_token.dart';
import 'package:isto_king/features/game/widgets/path_animated_token.dart';

const _defaultTokenSizeFactor = 0.4;

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.tokens,
    required this.movableTokenIds,
    this.innerPathAccess = const [false, false, false, false],
    this.movePaths = const {},
    this.moveDelays = const {},
    this.onTokenTap,
    super.key,
  });

  static const moveAnimationCurve = Curves.easeInOutCubic;

  final List<TokenState> tokens;
  final Set<int> movableTokenIds;
  final List<bool> innerPathAccess;
  final Map<int, List<BoardCell>> movePaths;
  final Map<int, Duration> moveDelays;
  final ValueChanged<int>? onTokenTap;

  static Duration moveAnimationDurationFor(
    Map<int, List<BoardCell>> movePaths, {
    Map<int, Duration> moveDelays = const {},
  }) {
    return MoveAnimationTiming.totalDurationFor(
      paths: movePaths,
      delays: moveDelays,
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
              Positioned.fill(
                child: CustomPaint(
                  painter: GameBoardPainter(
                    innerPathAccess: innerPathAccess,
                  ),
                ),
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
        ..sort((first, second) => first.id.compareTo(second.id));

      if (entry.key == IstoBoardPaths.centerCell) {
        widgets.addAll(_buildCenterTokenWidgets(rect, cellSize, cellTokens));
        continue;
      }

      final tokenSize = _tokenSizeFor(cellSize, cellTokens.length);
      final centers = _tokenCenters(rect, cellTokens.length);
      final positionedTokens = [
        for (var index = 0; index < cellTokens.length; index++)
          MapEntry(cellTokens[index], centers[index]),
      ]..sort((first, second) {
          final firstMovable = movableTokenIds.contains(first.key.id);
          final secondMovable = movableTokenIds.contains(second.key.id);
          if (firstMovable == secondMovable) {
            return first.key.id.compareTo(second.key.id);
          }
          return firstMovable ? 1 : -1;
        });

      for (final positionedToken in positionedTokens) {
        final token = positionedToken.key;
        final center = positionedToken.value;
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
      final tokenSize = cellSize * _defaultTokenSizeFactor;
      widgets.add(
        PathAnimatedToken(
          key: ValueKey('move-${token.id}'),
          waypoints: entry.value,
          board: board,
          cellSize: cellSize,
          tokenSize: tokenSize,
          duration: MoveAnimationTiming.durationForPath(entry.value),
          startDelay: moveDelays[token.id] ?? Duration.zero,
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

  List<Widget> _buildCenterTokenWidgets(
    Rect rect,
    double cellSize,
    List<TokenState> tokens,
  ) {
    final tokensByPlayer = <int, List<TokenState>>{};
    for (final token in tokens) {
      tokensByPlayer.putIfAbsent(token.playerIndex, () => []).add(token);
    }

    final tokenSize = cellSize * _defaultTokenSizeFactor;
    final widgets = <Widget>[];
    for (final entry in tokensByPlayer.entries) {
      for (var index = 0; index < entry.value.length; index++) {
        final center = _centerHomeTokenCenter(
          rect,
          entry.key,
          stackIndex: index,
          stackCount: entry.value.length,
        );
        widgets.add(
          _positionedToken(
            token: entry.value[index],
            left: center.dx - tokenSize / 2,
            top: center.dy - tokenSize / 2,
            tokenSize: tokenSize,
          ),
        );
      }
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

  Offset _centerHomeTokenCenter(
    Rect rect,
    int playerIndex, {
    int stackIndex = 0,
    int stackCount = 1,
  }) {
    final inset = rect.width * 0.29;
    final radial = switch (playerIndex) {
      0 => const Offset(0, -1),
      1 => const Offset(1, 0),
      2 => const Offset(-1, 0),
      3 => const Offset(0, 1),
      _ => Offset.zero,
    };
    final tangent = Offset(-radial.dy, radial.dx);
    final base = rect.center + radial * inset;
    final spread = rect.width * 0.085;
    final rowGap = rect.width * 0.075;

    final offset = switch (stackCount) {
      <= 1 => Offset.zero,
      2 => tangent * (stackIndex == 0 ? -spread : spread),
      3 => [
          tangent * -spread + radial * rowGap,
          tangent * spread + radial * rowGap,
          radial * -rowGap,
        ][stackIndex],
      _ => [
          tangent * -spread + radial * rowGap,
          tangent * spread + radial * rowGap,
          tangent * -spread + radial * -rowGap,
          tangent * spread + radial * -rowGap,
        ][stackIndex % 4],
    };

    return base + offset;
  }

  double _tokenSizeFor(double cellSize, int count) {
    return cellSize * _defaultTokenSizeFactor;
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
    if (count == 5) {
      return [
        rect.center.translate(-spread, 0),
        rect.center.translate(0, -spread),
        rect.center.translate(0, spread),
        rect.center.translate(spread, 0),
        rect.center,
      ];
    }
    if (count >= 7 && count <= 9) {
      final rowSpread = rect.width * 0.25;
      final rowGap = rect.height * 0.28;
      final centers = [
        rect.center.translate(-rowSpread, -rowGap),
        rect.center.translate(0, -rowGap),
        rect.center.translate(rowSpread, -rowGap),
        rect.center.translate(-rowSpread, rowGap),
        rect.center.translate(0, rowGap),
        rect.center.translate(rowSpread, rowGap),
        rect.center,
        rect.center.translate(-rowSpread, 0),
        rect.center.translate(rowSpread, 0),
      ];
      return centers.take(count).toList();
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
