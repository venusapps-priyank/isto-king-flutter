import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/player_info.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/widgets/game_board.dart';
import 'package:isto_king/features/game/widgets/player_card.dart';
import 'package:isto_king/features/game/widgets/player_row.dart';
import 'package:isto_king/features/game/widgets/top_game_bar.dart';

class IstoGameScreen extends StatefulWidget {
  const IstoGameScreen({super.key});

  @override
  State<IstoGameScreen> createState() => _IstoGameScreenState();
}

class _IstoGameScreenState extends State<IstoGameScreen> {
  final GameTurnController _turnController = GameTurnController();
  bool _isMoveAnimating = false;
  int _moveAnimationCycle = 0;
  Map<int, List<BoardCell>> _activeMovePaths = {};

  void _handleRollComplete(int playerIndex, int value) {
    if (_isMoveAnimating) return;

    setState(() {
      _turnController.handleRollComplete(playerIndex, value);
    });
  }

  void _handleTokenTap(int tokenId) {
    if (_isMoveAnimating) return;

    var didMove = false;
    Map<int, List<BoardCell>> movePaths = {};
    setState(() {
      final resolution = _turnController.moveToken(tokenId);
      didMove = resolution != null;
      if (didMove) {
        movePaths = resolution!.animationPaths;
        _activeMovePaths = movePaths;
        _isMoveAnimating = true;
        _moveAnimationCycle++;
      }
    });

    if (!didMove) return;

    final animationCycle = _moveAnimationCycle;
    final animationDuration = GameBoard.moveAnimationDurationFor(movePaths);
    Future<void>.delayed(animationDuration, () {
      if (!mounted || animationCycle != _moveAnimationCycle) return;
      setState(() {
        _isMoveAnimating = false;
        _activeMovePaths = {};
      });
    });
  }

  PlayerCard _buildPlayerCard(PlayerInfo player) {
    return PlayerCard(
      name: player.name,
      color: player.color,
      avatarAsset: player.avatarAsset,
      avatarOnRight: player.avatarOnRight,
      isActive: _turnController.currentPlayerIndex == player.index,
      canRoll: !_isMoveAnimating && _turnController.canRoll(player.index),
      onRollComplete: (value) => _handleRollComplete(player.index, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: ScreenOrnamentPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final compact = height < 820;
                  final horizontalPadding = width < 410 ? 12.0 : 16.0;
                  final topBarHeight = compact ? 58.0 : 66.0;
                  final cardHeight = compact ? 90.0 : 100.0;
                  const gap = 7.0;
                  final boardMaxWidth = width - horizontalPadding * 2;
                  final boardMaxHeight =
                      height - topBarHeight - cardHeight * 2 - gap * 3;
                  final boardSize = math.max(
                    280.0,
                    math.min(boardMaxWidth, boardMaxHeight),
                  );

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: topBarHeight,
                          child: TopGameBar(
                            message: _turnController.statusMessage,
                            activeColor:
                                gamePlayers[_turnController.currentPlayerIndex]
                                    .color,
                          ),
                        ),
                        const SizedBox(height: gap),
                        SizedBox(
                          height: cardHeight,
                          child: PlayerRow(
                            left: _buildPlayerCard(topRowPlayers[0]),
                            right: _buildPlayerCard(topRowPlayers[1]),
                          ),
                        ),
                        const SizedBox(height: gap),
                        Center(
                          child: SizedBox.square(
                            dimension: boardSize,
                            child: GameBoard(
                              tokens: _turnController.tokens,
                              movableTokenIds: _isMoveAnimating
                                  ? const {}
                                  : _turnController.legalTokenIds,
                              movePaths: _activeMovePaths,
                              onTokenTap: _handleTokenTap,
                            ),
                          ),
                        ),
                        const SizedBox(height: gap),
                        SizedBox(
                          height: cardHeight,
                          child: PlayerRow(
                            left: _buildPlayerCard(bottomRowPlayers[0]),
                            right: _buildPlayerCard(bottomRowPlayers[1]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
