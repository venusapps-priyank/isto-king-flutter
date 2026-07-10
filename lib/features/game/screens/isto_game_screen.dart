import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:isto_king/core/widgets/app_screen_scaffold.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/data/computer_names_repository.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/controllers/computer_turn_orchestrator.dart';
import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/data/saved_game_repository.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/game_setup_config.dart';
import 'package:isto_king/features/game/models/player_info.dart';
import 'package:isto_king/features/game/painters/screen_ornament_painter.dart';
import 'package:isto_king/features/game/widgets/animated_player_row.dart';
import 'package:isto_king/features/game/widgets/game_board.dart';
import 'package:isto_king/features/game/widgets/pause_game_dialog.dart';
import 'package:isto_king/features/game/widgets/player_card.dart';
import 'package:isto_king/features/game/widgets/top_game_bar.dart';
import 'package:isto_king/features/daily_reward/widgets/daily_reward_dialog.dart';
import 'package:isto_king/features/game/widgets/win_ranking_panel.dart';
import 'package:isto_king/features/rules/models/game_rules_settings.dart';

class IstoGameScreen extends StatefulWidget {
  const IstoGameScreen({
    this.setup = GameSetupConfig.defaultConfig,
    this.initialTurnController,
    super.key,
  });

  final GameSetupConfig setup;
  final GameTurnController? initialTurnController;

  @override
  State<IstoGameScreen> createState() => _IstoGameScreenState();
}

class _IstoGameScreenState extends State<IstoGameScreen>
    with WidgetsBindingObserver {
  late List<PlayerInfo> _players = buildGamePlayers(widget.setup);
  late GameTurnController _turnController = _createTurnController(
    useInitialController: true,
  );
  late final ComputerTurnOrchestrator _computerTurns =
      ComputerTurnOrchestrator();
  final SavedGameRepository _savedGameRepository = SavedGameRepository();
  bool _isMoveAnimating = false;
  int _moveAnimationCycle = 0;
  final List<int> _rollResetSerials = List<int>.filled(4, 0);
  final List<int> _autoRollSerials = List<int>.filled(4, 0);
  int? _cowrieRollingPlayerIndex;
  Map<int, List<BoardCell>> _activeMovePaths = {};
  Map<int, Duration> _activeMoveDelays = {};
  TokenPairCandidate? _visiblePairCandidate;
  int? _pairPromptTokenId;
  int? _centerChoiceTokenId;
  bool _showWinRankingPreview = false;

  GameTurnController _createTurnController({
    bool useInitialController = false,
  }) {
    final initialTurnController = widget.initialTurnController;
    if (useInitialController && initialTurnController != null) {
      return initialTurnController;
    }

    return GameTurnController(
      activePlayers: widget.setup.activePlayerIndexSet,
      mustKillForInner: widget.setup.rulesSettings.mustKillForInner,
      killPermissionReset: widget.setup.rulesSettings.isSettingActive(
        GameRuleSettingKey.killPermissionReset,
      ),
    );
  }

  bool get _shouldPersistMatch => true;

  bool _isPlayerActive(int playerIndex) {
    return widget.setup.activePlayerIndexSet.contains(playerIndex);
  }

  bool _isComputerPlayer(int playerIndex) {
    return widget.setup.computerPlayerIndexes.contains(playerIndex);
  }

  bool _isHumanTurn() {
    return !_isComputerPlayer(_turnController.currentPlayerIndex);
  }

  void _triggerComputerRoll(int playerIndex) {
    setState(() => _autoRollSerials[playerIndex]++);
  }

  void _scheduleComputerTurn() {
    if (!widget.setup.isVsComputer) return;
    _computerTurns.scheduleTurn(
      isMounted: () => mounted,
      isComputerPlayer: _isComputerPlayer,
      isMoveAnimating: () => _isMoveAnimating,
      isCowrieRolling: () => _cowrieRollingPlayerIndex != null,
      hasVisiblePairPrompt: () =>
          _visiblePairCandidate != null || _centerChoiceTokenId != null,
      controller: () => _turnController,
      onTriggerRoll: _triggerComputerRoll,
      onPairAfterRoll: _handleComputerPairAfterRoll,
      onMoveChoice: _handleComputerMoveChoice,
    );
  }

  void _handleComputerPairAfterRoll(TokenPairCandidate candidate) {
    _computerTurns.handlePairAfterRoll(
      controller: _turnController,
      candidate: candidate,
      onJoinPair: (pairCandidate) {
        final tokenId = pairCandidate.tokenIds.first;
        var locked = false;
        setState(() {
          locked = _turnController.lockTokenPairForPendingMove(
            pairCandidate.tokenIds,
          );
        });
        if (locked) {
          _moveToken(tokenId);
        } else {
          _handleComputerMoveChoice();
        }
      },
      onMoveChoice: _handleComputerMoveChoice,
    );
  }

  void _handleComputerMoveChoice() {
    final tokenId = _computerTurns.chooseTokenId(_turnController);
    if (tokenId == null) {
      _scheduleComputerTurn();
      return;
    }
    _handleTokenTap(tokenId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _assignRandomComputerNames();
    _saveGameIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scheduleComputerTurn(),
    );
  }

  Future<void> _assignRandomComputerNames() async {
    if (!widget.setup.isVsComputer) return;

    try {
      final computerIndexes = widget.setup.computerPlayerIndexes.toList()
        ..sort();
      final allNames = await ComputerNamesRepository.loadNames();
      final pickedNames = ComputerNamesRepository.pickRandomNames(
        allNames,
        computerIndexes.length,
      );
      final computerNamesByIndex = {
        for (var i = 0; i < computerIndexes.length; i++)
          computerIndexes[i]: pickedNames[i],
      };

      if (!mounted) return;
      setState(() {
        _players = buildGamePlayers(
          widget.setup,
          computerNamesByIndex: computerNamesByIndex,
        );
      });
    } on Object {
      // Keep fallback "Computer 1/2/3" names if the asset cannot be loaded.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _computerTurns.cancelPendingTurns();
    _saveGameIfNeeded();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveGameIfNeeded();
    }
  }

  Future<void> _saveGameIfNeeded() async {
    if (!_shouldPersistMatch) return;
    if (_turnController.isGameOver) {
      await _savedGameRepository.clear(
        isPassAndPlay: widget.setup.isPassAndPlay,
      );
      return;
    }
    await _savedGameRepository.save(
      SavedGame(setup: widget.setup, turnController: _turnController),
    );
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
      _cowrieRollingPlayerIndex = null;
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
      _centerChoiceTokenId = null;
      final resolution = _turnController.handleRollComplete(playerIndex, value);
      if (resolution != null &&
          resolution.discarded &&
          resolution.grantsExtraTurn) {
        _rollResetSerials[playerIndex]++;
      }
      pairCandidate = _turnController.pairCandidateForPendingMove;
      if (pairCandidate == null && !_isComputerPlayer(playerIndex)) {
        autoMoveTokenId = _turnController.autoMoveTokenId;
      }
    });
    _saveGameIfNeeded();

    if (pairCandidate != null) {
      if (_isComputerPlayer(playerIndex)) {
        _handleComputerPairAfterRoll(pairCandidate!);
      }
      return;
    }

    if (_isComputerPlayer(playerIndex)) {
      if (_turnController.hasPendingMove) {
        Future<void>.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          if (_turnController.currentPlayerIndex != playerIndex) return;
          _handleComputerMoveChoice();
        });
      } else {
        _scheduleComputerTurn();
      }
      return;
    }

    if (autoMoveTokenId != null) {
      _handleTokenTap(autoMoveTokenId!);
      return;
    }

    _scheduleComputerTurn();
  }

  void _handleTokenTap(int tokenId) {
    if (_isMoveAnimating) return;

    final pairCandidate = _turnController.pairCandidateForToken(tokenId);
    if (pairCandidate != null) {
      if (_isComputerPlayer(_turnController.currentPlayerIndex)) {
        _computerTurns.handlePairPrompt(
          controller: _turnController,
          candidate: pairCandidate,
          tokenId: tokenId,
          onJoinPair: (candidate, selectedTokenId) {
            var locked = false;
            setState(() {
              locked = _turnController.lockTokenPairForPendingMove(
                candidate.tokenIds,
              );
              _visiblePairCandidate = null;
              _pairPromptTokenId = null;
            });
            if (locked) {
              _moveToken(selectedTokenId);
            } else {
              _moveToken(selectedTokenId);
            }
          },
          onPlaySingle: (selectedTokenId) {
            setState(() {
              _visiblePairCandidate = null;
              _pairPromptTokenId = null;
            });
            _moveToken(selectedTokenId);
          },
        );
        return;
      }
      setState(() {
        _visiblePairCandidate = pairCandidate;
        _pairPromptTokenId = tokenId;
        _centerChoiceTokenId = null;
      });
      return;
    }

    if (_turnController.centerChoiceAvailableForToken(tokenId)) {
      if (_isComputerPlayer(_turnController.currentPlayerIndex)) {
        _moveToken(tokenId);
        return;
      }
      setState(() {
        _visiblePairCandidate = null;
        _pairPromptTokenId = null;
        _centerChoiceTokenId = tokenId;
      });
      return;
    }

    _moveToken(tokenId);
  }

  void _moveToken(
    int tokenId, {
    CenterMoveChoice centerChoice = CenterMoveChoice.enterCenter,
  }) {
    var didMove = false;
    Map<int, List<BoardCell>> movePaths = {};
    Map<int, Duration> moveDelays = {};
    setState(() {
      _visiblePairCandidate = null;
      _pairPromptTokenId = null;
      _centerChoiceTokenId = null;
      final resolution = _turnController.moveToken(
        tokenId,
        centerChoice: centerChoice,
      );
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
    _saveGameIfNeeded();

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
      _saveGameIfNeeded();
      _scheduleComputerTurn();
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
      if (_turnController.centerChoiceAvailableForToken(tokenId)) {
        setState(() {
          _centerChoiceTokenId = tokenId;
        });
        return;
      }
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
    if (_turnController.centerChoiceAvailableForToken(tokenId)) {
      setState(() {
        _centerChoiceTokenId = tokenId;
      });
      return;
    }
    _moveToken(tokenId);
  }

  void _handleGoCenterPrompt() {
    final tokenId = _centerChoiceTokenId;
    if (tokenId == null) return;

    _moveToken(tokenId);
  }

  void _handleCircleAheadPrompt() {
    final tokenId = _centerChoiceTokenId;
    if (tokenId == null) return;

    _moveToken(
      tokenId,
      centerChoice: CenterMoveChoice.stayOnInnerCircle,
    );
  }

  void _resetGame() {
    _computerTurns.cancelPendingTurns();
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
      _centerChoiceTokenId = null;
      _cowrieRollingPlayerIndex = null;
      _showWinRankingPreview = false;
    });
    _saveGameIfNeeded();
    _scheduleComputerTurn();
  }

  void _dismissWinPanelPreview() {
    setState(() {
      _showWinRankingPreview = false;
    });
  }

  void _handleHomeTap() {
    _saveGameIfNeeded();
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
        _saveGameIfNeeded();
        _handleHomeTap();
      },
    );
  }

  PlayerCard _buildPlayerCard(PlayerInfo player) {
    final isCurrentPlayer = _turnController.currentPlayerIndex == player.index;
    final isComputer = _isComputerPlayer(player.index);
    final isRollingCowries = _cowrieRollingPlayerIndex == player.index;
    final canRoll =
        !_isMoveAnimating &&
        !isRollingCowries &&
        _turnController.canRoll(player.index);
    final showShells =
        isCurrentPlayer &&
        (canRoll || _turnController.pendingRoll != null || isRollingCowries);

    return PlayerCard(
      name: player.name,
      color: player.color,
      avatarAsset: player.avatarAsset,
      avatarOnRight: player.avatarOnRight,
      isActive: isCurrentPlayer,
      showShells: showShells,
      canRoll: canRoll,
      enableTap: !isComputer,
      autoRollSerial: _autoRollSerials[player.index],
      rollResetSerial: _rollResetSerials[player.index],
      finishRank: _turnController.rankForPlayer(player.index),
      onRollStarted: isComputer && isCurrentPlayer
          ? () => setState(() => _cowrieRollingPlayerIndex = player.index)
          : null,
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
      for (final index in ranked) playerInfoForIndex(_players, index),
      ...unranked,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AppScreenScaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ScreenOrnamentPainter(topInset: topInset),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: topInset,
              child: const ColoredBox(color: RoyalColors.outerRed),
            ),
            const _BottomCornerMandala(isLeft: true),
            const _BottomCornerMandala(isLeft: false),
            SafeArea(
              bottom: false,
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
                  final centeredSectionHeight = height;
                  final boardMaxHeight =
                      centeredSectionHeight - cardHeight * 2 - gap * 2;
                  final boardSize = math.max(
                    280.0,
                    math.min(boardMaxWidth, boardMaxHeight),
                  );
                  final showWinRanking =
                      _turnController.isGameOver || _showWinRankingPreview;
                  final isActualGameOver = _turnController.isGameOver;

                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                          movableTokenIds:
                                              _isMoveAnimating ||
                                                  !_isHumanTurn()
                                              ? const {}
                                              : _turnController.legalTokenIds,
                                          innerPathAccess:
                                              _turnController.innerPathAccess,
                                          movePaths: _activeMovePaths,
                                          moveDelays: _activeMoveDelays,
                                          pairPromptTokenIds:
                                              _visiblePairCandidate?.tokenIds,
                                          centerChoiceTokenId:
                                              _centerChoiceTokenId,
                                          onJoinPairPrompt:
                                              _handleJoinPairPrompt,
                                          onDismissPairPrompt:
                                              _handlePlaySinglePairPrompt,
                                          onGoCenterPrompt:
                                              _handleGoCenterPrompt,
                                          onCircleAheadPrompt:
                                              _handleCircleAheadPrompt,
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
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: topBarHeight,
                              child: TopGameBar(
                                onBackTap: _handleHomeTap,
                                onSettingsTap: _handleSettingsTap,
                                onCoinAddTap: () => DailyRewardDialog.show(context),
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
                              onPlayAgain: isActualGameOver
                                  ? _resetGame
                                  : _dismissWinPanelPreview,
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
