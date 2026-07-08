import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/game_setup_config.dart';
import 'package:isto_king/features/game/models/player_info.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/widgets/animated_player_row.dart';
import 'package:isto_king/features/game/widgets/game_board.dart';
import 'package:isto_king/features/game/widgets/pause_game_dialog.dart';
import 'package:isto_king/features/game/widgets/player_card.dart';
import 'package:isto_king/features/game/widgets/top_game_bar.dart';
import 'package:isto_king/features/game/widgets/win_ranking_panel.dart';

class IstoGameScreen extends StatefulWidget {
  const IstoGameScreen({
    this.setup = GameSetupConfig.defaultConfig,
    super.key,
  });

  final GameSetupConfig setup;

  @override
  State<IstoGameScreen> createState() => _IstoGameScreenState();
}

class _IstoGameScreenState extends State<IstoGameScreen> {
  late final List<PlayerInfo> _players = buildGamePlayers(widget.setup);
  late GameTurnController _turnController = _createTurnController();
  bool _isMoveAnimating = false;
  int _moveAnimationCycle = 0;
  final List<int> _rollResetSerials = List<int>.filled(4, 0);
  Map<int, List<BoardCell>> _activeMovePaths = {};
  Map<int, Duration> _activeMoveDelays = {};
  TokenPairCandidate? _visiblePairCandidate;
  int? _pairPromptTokenId;

  GameTurnController _createTurnController() {
    return GameTurnController(
      activePlayers: widget.setup.activePlayerIndexSet,
    );
  }

  bool _isPlayerActive(int playerIndex) {
    return widget.setup.activePlayerIndexSet.contains(playerIndex);
  }

  Widget _buildPlayerSlot(int playerIndex) {
    if (!_isPlayerActive(playerIndex)) {
      return const SizedBox.shrink();
    }
    return _buildPlayerCard(playerInfoForIndex(_players, playerIndex));
  }

  void _handleRollComplete(int playerIndex, int value) {
    if (_isMoveAnimating) return;

    int? autoMoveTokenId;
    TokenPairCandidate? pairCandidate;
    setState(() {
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
      final resolution = _turnController.handleRollComplete(playerIndex, value);
      if (resolution != null &&
          resolution.discarded &&
          resolution.grantsExtraTurn) {
        _rollResetSerials[playerIndex]++;
      }
      pairCandidate = _turnController.pairCandidateForPendingMove;
      if (pairCandidate == null) {
        autoMoveTokenId = _turnController.autoMoveTokenId;
      }
    });

    if (pairCandidate != null) {
      return;
    }

    if (autoMoveTokenId != null) {
      _handleTokenTap(autoMoveTokenId!);
    }
  }

  void _handleTokenTap(int tokenId) {
    if (_isMoveAnimating) return;

    final pairCandidate = _turnController.pairCandidateForToken(tokenId);
    if (pairCandidate != null) {
      setState(() {
        _visiblePairCandidate = pairCandidate;
        _pairPromptTokenId = tokenId;
      });
      return;
    }

    _moveToken(tokenId);
  }

  void _moveToken(int tokenId) {
    var didMove = false;
    Map<int, List<BoardCell>> movePaths = {};
    Map<int, Duration> moveDelays = {};
    setState(() {
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
      final resolution = _turnController.moveToken(tokenId);
      didMove = resolution != null;
      if (didMove) {
        movePaths = resolution!.animationPaths;
        moveDelays = resolution.animationDelays;
        _activeMovePaths = movePaths;
        _activeMoveDelays = moveDelays;
        _isMoveAnimating = true;
        _moveAnimationCycle++;
      }
    });

    if (!didMove) return;

    final animationCycle = _moveAnimationCycle;
    final animationDuration = GameBoard.moveAnimationDurationFor(
      movePaths,
      moveDelays: moveDelays,
    );
    Future<void>.delayed(animationDuration, () {
      if (!mounted || animationCycle != _moveAnimationCycle) return;
      setState(() {
        _isMoveAnimating = false;
        _activeMovePaths = {};
        _activeMoveDelays = {};
      });
    });
  }

  void _handleJoinPairPrompt() {
    final candidate = _visiblePairCandidate;
    final tokenId = _pairPromptTokenId;
    if (candidate == null || tokenId == null) return;

    var locked = false;
    setState(() {
      locked = _turnController.lockTokenPairForPendingMove(candidate.tokenIds);
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
    });
    if (locked) {
      _moveToken(tokenId);
    }
  }

  void _handlePlaySinglePairPrompt() {
    final tokenId = _pairPromptTokenId;
    if (tokenId == null) return;

    setState(() {
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
    });
    _moveToken(tokenId);
  }

  void _resetGame() {
    setState(() {
      _turnController = _createTurnController();
      _isMoveAnimating = false;
      _moveAnimationCycle = 0;
      for (var i = 0; i < _rollResetSerials.length; i++) {
        _rollResetSerials[i] = 0;
      }
      _activeMovePaths = {};
      _activeMoveDelays = {};
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
    });
  }

  void _handleHomeTap() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    _resetGame();
  }

  void _handleSettingsTap() {
    PauseGameDialog.show(
      context,
      onResume: () => Navigator.of(context).pop(),
      onRestart: () {
        Navigator.of(context).pop();
        _resetGame();
      },
      onQuitMatch: () {
        Navigator.of(context).pop();
        _handleHomeTap();
      },
    );
  }

  PlayerCard _buildPlayerCard(PlayerInfo player) {
    final isCurrentPlayer = _turnController.currentPlayerIndex == player.index;
    final canRoll = !_isMoveAnimating && _turnController.canRoll(player.index);
    final showShells =
        isCurrentPlayer && (canRoll || _turnController.pendingRoll != null);

    return PlayerCard(
      name: player.name,
      color: player.color,
      avatarAsset: player.avatarAsset,
      avatarOnRight: player.avatarOnRight,
      isActive: isCurrentPlayer,
      showShells: showShells,
      canRoll: canRoll,
      rollResetSerial: _rollResetSerials[player.index],
      finishRank: _turnController.rankForPlayer(player.index),
      onRollComplete: (value) => _handleRollComplete(player.index, value),
    );
  }

  List<PlayerInfo> _playersByRank() {
    final ranked = _turnController.rankedPlayerIndexes;
    final unranked = _players.where(
      (player) =>
          _isPlayerActive(player.index) && !ranked.contains(player.index),
    );
    return [
      for (final index in ranked)
        playerInfoForIndex(_players, index),
      ...unranked,
    ];
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
            const _BottomCornerMandala(isLeft: true),
            const _BottomCornerMandala(isLeft: false),
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
                  final showWinRanking = _turnController.isGameOver;

                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: topBarHeight,
                              child: TopGameBar(
                                onBackTap: _handleHomeTap,
                                onSettingsTap: _handleSettingsTap,
                              ),
                            ),
                            const SizedBox(height: gap),
                            SizedBox(
                              height: cardHeight,
                              child: AnimatedPlayerRow(
                                visible: !showWinRanking,
                                isTopRow: true,
                                left: _buildPlayerSlot(0),
                                right: _buildPlayerSlot(1),
                              ),
                            ),
                            const SizedBox(height: gap),
                            Center(
                              child: SizedBox.square(
                                dimension: boardSize,
                                child: GameBoard(
                                  players: _players,
                                  tokens: _turnController.tokens,
                                  movableTokenIds: _isMoveAnimating
                                      ? const {}
                                      : _turnController.legalTokenIds,
                                  innerPathAccess:
                                      _turnController.innerPathAccess,
                                  movePaths: _activeMovePaths,
                                  moveDelays: _activeMoveDelays,
                                  pairPromptTokenIds:
                                      _visiblePairCandidate?.tokenIds,
                                  onJoinPairPrompt: _handleJoinPairPrompt,
                                  onDismissPairPrompt:
                                      _handlePlaySinglePairPrompt,
                                  onTokenTap: _handleTokenTap,
                                ),
                              ),
                            ),
                            const SizedBox(height: gap),
                            SizedBox(
                              height: cardHeight,
                              child: AnimatedPlayerRow(
                                visible: !showWinRanking,
                                isTopRow: false,
                                left: _buildPlayerSlot(2),
                                right: _buildPlayerSlot(3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showWinRanking) ...[
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: WinRankingPanel(
                              playersByRank: _playersByRank(),
                              onPlayAgain: _resetGame,
                              onHome: _handleHomeTap,
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _BottomCornerMandala extends StatelessWidget {
  const _BottomCornerMandala({required this.isLeft});

  static const _asset = 'assets/images/corner_mandala.png';
  static const _imageSize = 156.0;

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    const offset = -_imageSize / 2;

    return Positioned(
      left: isLeft ? offset : null,
      right: isLeft ? null : offset,
      bottom: offset,
      width: _imageSize,
      height: _imageSize,
      child: IgnorePointer(child: Image.asset(_asset, fit: BoxFit.contain)),
    );
  }
}
