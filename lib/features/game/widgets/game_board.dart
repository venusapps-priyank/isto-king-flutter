import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/logic/move_animation_timing.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/player_info.dart';
import 'package:isto_king/features/game/models/token_state.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';
import 'package:isto_king/features/game/widgets/game_token.dart';
import 'package:isto_king/features/game/widgets/path_animated_token.dart';

const _defaultTokenSizeFactor = 0.4;
const _tokenJoinAnimationDuration = Duration(milliseconds: 260);

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.tokens,
    required this.players,
    required this.movableTokenIds,
    this.innerPathAccess = const [false, false, false, false],
    this.movePaths = const {},
    this.moveDelays = const {},
    this.pairPromptTokenIds,
    this.onJoinPairPrompt,
    this.onDismissPairPrompt,
    this.onTokenTap,
    super.key,
  });

  static const moveAnimationCurve = Curves.easeInOutCubic;

  final List<TokenState> tokens;
  final List<PlayerInfo> players;
  final Set<int> movableTokenIds;
  final List<bool> innerPathAccess;
  final Map<int, List<BoardCell>> movePaths;
  final Map<int, Duration> moveDelays;
  final List<int>? pairPromptTokenIds;
  final VoidCallback? onJoinPairPrompt;
  final VoidCallback? onDismissPairPrompt;
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

  PlayerInfo _playerFor(int playerIndex) {
    return players.firstWhere((player) => player.index == playerIndex);
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
                  painter: GameBoardPainter(innerPathAccess: innerPathAccess),
                ),
              ),
              ..._buildTokenWidgets(inner, cellSize),
              if (pairPromptTokenIds != null)
                _buildPairPrompt(inner, cellSize, pairPromptTokenIds!),
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
      final visualGroups = _visualGroupsFor(cellTokens);
      final groupCenters = _visualGroupCenters(rect, visualGroups);
      final movablePairTokenIds = <int>{};
      final positionedTokens = <MapEntry<TokenState, Offset>>[];

      for (var index = 0; index < visualGroups.length; index++) {
        final group = visualGroups[index];
        final groupCenter = groupCenters[index];

        if (group.isLockedPair) {
          final pairCenters = _lockedPairCenters(groupCenter, tokenSize);
          final pairIsMovable = group.tokens.any(
            (token) => movableTokenIds.contains(token.id),
          );
          if (pairIsMovable) {
            movablePairTokenIds.addAll(group.tokens.map((token) => token.id));
            widgets.add(
              _positionedPairHighlight(
                tokens: group.tokens,
                centers: pairCenters,
                tokenSize: tokenSize,
              ),
            );
          }
          for (
            var tokenIndex = 0;
            tokenIndex < group.tokens.length;
            tokenIndex++
          ) {
            positionedTokens.add(
              MapEntry(group.tokens[tokenIndex], pairCenters[tokenIndex]),
            );
          }
          continue;
        }

        positionedTokens.add(MapEntry(group.tokens.single, groupCenter));
      }

      positionedTokens.sort((first, second) {
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
            showMovableHighlight: !movablePairTokenIds.contains(token.id),
          ),
        );
      }
    }

    final renderedMovingTokenIds = <int>{};
    for (final entry in movePaths.entries) {
      if (renderedMovingTokenIds.contains(entry.key)) continue;

      final token = tokens.firstWhere((candidate) => candidate.id == entry.key);
      final tokenSize = cellSize * _defaultTokenSizeFactor;
      final pairedMovingToken = _pairedMovingTokenFor(token, entry.value);
      if (pairedMovingToken != null) {
        final movingPairTokens = [token, pairedMovingToken]
          ..sort((first, second) => first.id.compareTo(second.id));
        final pairSize = _lockedPairPieceSize(tokenSize);
        renderedMovingTokenIds.addAll(
          movingPairTokens.map((movingToken) => movingToken.id),
        );
        widgets.add(
          PathAnimatedToken(
            key: ValueKey(
              'move-pair-${movingPairTokens.map((token) => token.id).join('-')}',
            ),
            waypoints: entry.value,
            board: board,
            cellSize: cellSize,
            tokenSize: tokenSize,
            childSize: pairSize,
            duration: MoveAnimationTiming.durationForPath(entry.value),
            startDelay: moveDelays[token.id] ?? Duration.zero,
            curve: moveAnimationCurve,
            child: _movingLockedPairPiece(
              tokens: movingPairTokens,
              tokenSize: tokenSize,
              size: pairSize,
            ),
          ),
        );
        continue;
      }

      renderedMovingTokenIds.add(token.id);
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
            color: _playerFor(token.playerIndex).color,
            size: tokenSize,
            isMovable: false,
            semanticLabel:
                '${_playerFor(token.playerIndex).name} token ${token.tokenIndex + 1}',
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildPairPrompt(Rect board, double cellSize, List<int> tokenIds) {
    if (tokenIds.length != 2) return const SizedBox.shrink();

    final promptTokens = [
      for (final token in tokens)
        if (tokenIds.contains(token.id)) token,
    ];
    if (promptTokens.length != 2) return const SizedBox.shrink();

    final cell = _cellForToken(promptTokens.first);
    if (_cellForToken(promptTokens.last) != cell) {
      return const SizedBox.shrink();
    }

    const promptWidth = 142.0;
    const promptHeight = 72.0;
    const pointerWidth = 14.0;
    const cornerRadius = 14.0;
    const pointerHeight = 7.0;
    const gap = 8.0;
    const lowerOffset = 6.0;
    final cellRect = _cellRect(board, cellSize, cell);
    final left = (cellRect.center.dx - promptWidth / 2)
        .clamp(board.left, board.right - promptWidth)
        .toDouble();
    final top = math.max(
      board.top + 2,
      cellRect.top - promptHeight - pointerHeight - gap,
    ) +
        lowerOffset;

    return Positioned(
      left: left,
      top: top,
      width: promptWidth,
      height: promptHeight + pointerHeight,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: promptHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DA),
                border: Border.all(
                  color: const Color(0xFF8B5A2B).withValues(alpha: 0.76),
                  width: 1.1,
                ),
                borderRadius: BorderRadius.circular(cornerRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE9D49F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.link_rounded,
                            size: 13,
                            color: Color(0xFF6A3F1D),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Make a pair?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF5B3517),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onJoinPairPrompt,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF189FE7), Color(0xFF0C7FC0)],
                              ),
                              border: Border.all(
                                color: const Color(0xFF06679D).withValues(alpha: 0.78),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0B83C5).withValues(alpha: 0.28),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const SizedBox(
                              width: 80,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'Join',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Tooltip(
                            message: 'Play single',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onDismissPairPrompt,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E5BC),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF8B5A2B,
                                    ).withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: const Color(
                                    0xFF6A3F1D,
                                  ).withValues(alpha: 0.92),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: promptHeight - 1,
              left: (cellRect.center.dx - left - pointerWidth / 2)
                  .clamp(
                    cornerRadius + 2,
                    promptWidth - cornerRadius - pointerWidth - 2,
                  )
                  .toDouble(),
              child: CustomPaint(
                size: const Size(pointerWidth, pointerHeight),
                painter: _PairPromptPointerPainter(
                  fillColor: const Color(0xFFFFF6DA),
                  borderColor: const Color(0xFF8B5A2B).withValues(alpha: 0.76),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TokenState? _pairedMovingTokenFor(TokenState token, List<BoardCell> path) {
    final pairedTokenId = token.pairedTokenId;
    if (pairedTokenId == null || !movePaths.containsKey(pairedTokenId)) {
      return null;
    }

    final pairedToken = tokens.firstWhere(
      (candidate) => candidate.id == pairedTokenId,
    );
    if (pairedToken.pairedTokenId != token.id ||
        pairedToken.playerIndex != token.playerIndex ||
        !_samePath(path, movePaths[pairedTokenId]!)) {
      return null;
    }

    return pairedToken;
  }

  bool _samePath(List<BoardCell> first, List<BoardCell> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
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
    bool showMovableHighlight = true,
  }) {
    final isMovable = movableTokenIds.contains(token.id);
    return AnimatedPositioned(
      key: ValueKey(token.id),
      left: left,
      top: top,
      width: tokenSize,
      height: tokenSize,
      duration: _tokenJoinAnimationDuration,
      curve: Curves.easeOutBack,
      child: GameToken(
        color: _playerFor(token.playerIndex).color,
        size: tokenSize,
        isMovable: isMovable,
        showMovableHighlight: showMovableHighlight,
        semanticLabel:
            '${_playerFor(token.playerIndex).name} token ${token.tokenIndex + 1}',
        onTap: () => onTokenTap?.call(token.id),
      ),
    );
  }

  Widget _positionedPairHighlight({
    required List<TokenState> tokens,
    required List<Offset> centers,
    required double tokenSize,
  }) {
    final horizontalPadding = tokenSize * 0.16;
    final verticalPadding = tokenSize * 0.13;
    final left =
        centers.map((center) => center.dx).reduce(math.min) -
        tokenSize / 2 -
        horizontalPadding;
    final right =
        centers.map((center) => center.dx).reduce(math.max) +
        tokenSize / 2 +
        horizontalPadding;
    final top =
        centers.map((center) => center.dy).reduce(math.min) -
        tokenSize / 2 -
        verticalPadding;
    final bottom =
        centers.map((center) => center.dy).reduce(math.max) +
        tokenSize / 2 +
        verticalPadding;
    final firstToken = tokens.first;

    return AnimatedPositioned(
      key: ValueKey(
        'pair-highlight-${tokens.map((token) => token.id).join('-')}',
      ),
      left: left,
      top: top,
      width: right - left,
      height: bottom - top,
      duration: _tokenJoinAnimationDuration,
      curve: Curves.easeOutBack,
      child: IgnorePointer(
        child: _PulsingPairMoveHighlight(
          color: _playerFor(firstToken.playerIndex).color,
        ),
      ),
    );
  }

  Widget _movingLockedPairPiece({
    required List<TokenState> tokens,
    required double tokenSize,
    required Size size,
  }) {
    final pairGap = _lockedPairCenterSpread(tokenSize) * 2;

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < tokens.length; index++)
            Positioned(
              left: index * pairGap,
              top: 0,
              width: tokenSize,
              height: tokenSize,
              child: GameToken(
                color: _playerFor(tokens[index].playerIndex).color,
                size: tokenSize,
                isMovable: false,
                semanticLabel:
                    '${_playerFor(tokens[index].playerIndex).name} token ${tokens[index].tokenIndex + 1}',
              ),
            ),
        ],
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

  List<_TokenVisualGroup> _visualGroupsFor(List<TokenState> tokens) {
    final remainingTokenIds = tokens.map((token) => token.id).toSet();
    final groups = <_TokenVisualGroup>[];

    for (final token in tokens) {
      if (!remainingTokenIds.contains(token.id)) continue;

      final pairedTokenId = token.pairedTokenId;
      TokenState? pairedToken;
      if (pairedTokenId != null) {
        for (final candidate in tokens) {
          if (candidate.id == pairedTokenId) {
            pairedToken = candidate;
            break;
          }
        }
      }
      if (pairedToken != null &&
          pairedToken.pairedTokenId == token.id &&
          remainingTokenIds.contains(pairedToken.id)) {
        groups.add(
          _TokenVisualGroup(
            [token, pairedToken]
              ..sort((first, second) => first.id.compareTo(second.id)),
          ),
        );
        remainingTokenIds.remove(token.id);
        remainingTokenIds.remove(pairedToken.id);
        continue;
      }

      groups.add(_TokenVisualGroup([token]));
      remainingTokenIds.remove(token.id);
    }

    return groups;
  }

  List<Offset> _visualGroupCenters(Rect rect, List<_TokenVisualGroup> groups) {
    final count = groups.length;
    if (count == 1) return [rect.center];

    final spread = rect.width * 0.28;
    if (count == 2 && groups.any((group) => group.isLockedPair)) {
      final verticalSpread = rect.height * 0.19;
      return [
        rect.center.translate(0, -verticalSpread),
        rect.center.translate(0, verticalSpread),
      ];
    }
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

  List<Offset> _lockedPairCenters(Offset center, double tokenSize) {
    final pairSpread = _lockedPairCenterSpread(tokenSize);
    return [center.translate(-pairSpread, 0), center.translate(pairSpread, 0)];
  }

  double _lockedPairCenterSpread(double tokenSize) => tokenSize * 0.28;

  Size _lockedPairPieceSize(double tokenSize) {
    return Size(tokenSize + _lockedPairCenterSpread(tokenSize) * 2, tokenSize);
  }
}

class _TokenVisualGroup {
  const _TokenVisualGroup(this.tokens);

  final List<TokenState> tokens;

  bool get isLockedPair {
    if (tokens.length != 2) return false;

    final first = tokens[0];
    final second = tokens[1];
    return first.pairedTokenId == second.id && second.pairedTokenId == first.id;
  }
}

class _PairPromptPointerPainter extends CustomPainter {
  const _PairPromptPointerPainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _PairPromptPointerPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}

class _PulsingPairMoveHighlight extends StatefulWidget {
  const _PulsingPairMoveHighlight({required this.color});

  final Color color;

  @override
  State<_PulsingPairMoveHighlight> createState() =>
      _PulsingPairMoveHighlightState();
}

class _PulsingPairMoveHighlightState extends State<_PulsingPairMoveHighlight>
    with SingleTickerProviderStateMixin {
  static const _pulseDuration = Duration(milliseconds: 900);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulse = _pulseAnimation.value;
        return Transform.scale(
          scale: 1.0 + pulse * 0.14,
          child: CustomPaint(
            painter: _PairMoveHighlightPainter(
              color: widget.color,
              pulse: pulse,
            ),
          ),
        );
      },
    );
  }
}

class _PairMoveHighlightPainter extends CustomPainter {
  const _PairMoveHighlightPainter({required this.color, required this.pulse});

  final Color color;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.height / 2);
    final highlight = RRect.fromRectAndRadius(rect.deflate(1), radius);
    final outerColor = Color.lerp(color, Colors.white, 0.18)!;
    final innerColor = Color.lerp(color, Colors.white, 0.62)!;

    canvas.drawRRect(
      highlight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * (0.07 + pulse * 0.03)
        ..color = outerColor.withValues(alpha: 0.55 + pulse * 0.4),
    );
    canvas.drawRRect(
      highlight.deflate(size.height * 0.09),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.height * (0.04 + pulse * 0.015)
        ..color = innerColor.withValues(alpha: 0.55 + pulse * 0.3),
    );
  }

  @override
  bool shouldRepaint(covariant _PairMoveHighlightPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pulse != pulse;
  }
}
