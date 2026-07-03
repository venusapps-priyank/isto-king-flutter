import 'package:isto_king/data/game_constants.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/logic/move_animation_timing.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/player_game_state.dart';
import 'package:isto_king/features/game/models/token_state.dart';

class MoveResolution {
  const MoveResolution({
    required this.capturedCount,
    required this.reachedCenter,
    required this.grantsExtraTurn,
    required this.gameFinished,
    required this.animationPaths,
    this.animationDelays = const {},
  });

  final int capturedCount;
  final bool reachedCenter;
  final bool grantsExtraTurn;
  final bool gameFinished;
  final Map<int, List<BoardCell>> animationPaths;
  final Map<int, Duration> animationDelays;
}

class GameTurnController {
  int currentPlayerIndex = turnOrder.first;
  final List<int?> lastRolls = List<int?>.filled(4, null);
  final List<PlayerGameState> playerStates = List<PlayerGameState>.generate(
    4,
    (_) => PlayerGameState(),
  );
  final List<TokenState> _tokens = List<TokenState>.generate(
    16,
    (index) => TokenState(playerIndex: index ~/ 4, tokenIndex: index % 4),
  );

  int? pendingRoll;
  int? winnerIndex;
  Set<int> legalTokenIds = {};

  List<TokenState> get tokens => List<TokenState>.unmodifiable(_tokens);

  bool get hasPendingMove => pendingRoll != null && legalTokenIds.isNotEmpty;

  bool canRoll(int playerIndex) {
    return winnerIndex == null &&
        playerIndex == currentPlayerIndex &&
        pendingRoll == null;
  }

  BoardCell cellForToken(TokenState token) {
    if (token.isFinished) return IstoBoardPaths.centerCell;
    if (token.isAtStart) {
      return IstoBoardPaths.homeCellForPlayer(token.playerIndex);
    }
    return IstoBoardPaths.pathForPlayer(token.playerIndex)[token.pathIndex];
  }

  void handleRollComplete(int playerIndex, int value) {
    if (!canRoll(playerIndex)) return;

    lastRolls[playerIndex] = value;
    pendingRoll = value;
    legalTokenIds = _legalMovesFor(
      playerIndex,
      value,
    ).map((token) => token.id).toSet();

    if (legalTokenIds.isEmpty) {
      _handleNoLegalMove(playerIndex, value);
    }
  }

  MoveResolution? moveToken(int tokenId) {
    final roll = pendingRoll;
    if (roll == null || !legalTokenIds.contains(tokenId)) return null;

    final token = _tokenById(tokenId);
    if (token == null || token.playerIndex != currentPlayerIndex) return null;

    final targetPathIndex = _targetPathIndex(token, roll);
    if (targetPathIndex == null) return null;

    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final destination = path[targetPathIndex];
    final capturedTokens = _tokensToCapture(token, destination);
    final killerPath = _animationPathForMove(token, targetPathIndex);
    final animationPaths = <int, List<BoardCell>>{
      token.id: killerPath,
      for (final captured in capturedTokens)
        captured.id: _animationPathToStart(captured),
    };
    final killerDuration = MoveAnimationTiming.durationForPath(killerPath);
    final animationDelays = {
      for (final captured in capturedTokens) captured.id: killerDuration,
    };

    for (final capturedToken in capturedTokens) {
      capturedToken.sendToStart();
    }

    token
      ..isAtStart = false
      ..pathIndex = targetPathIndex
      ..isFinished = targetPathIndex == path.length - 1;

    if (capturedTokens.isNotEmpty) {
      playerStates[token.playerIndex].hasKilledOpponent = true;
    }
    for (final capturedToken in capturedTokens) {
      _resetKillPermissionIfAllAtStart(capturedToken.playerIndex);
    }

    final reachedCenter = token.isFinished;
    final grantsExtraTurn =
        _rollGrantsExtraTurn(roll) ||
        capturedTokens.isNotEmpty ||
        reachedCenter;
    final gameFinished = _tokens
        .where((candidate) => candidate.playerIndex == token.playerIndex)
        .every((candidate) => candidate.isFinished);

    pendingRoll = null;
    legalTokenIds = {};

    if (gameFinished) {
      winnerIndex = token.playerIndex;
    } else if (!grantsExtraTurn) {
      _advanceTurn();
    }

    return MoveResolution(
      capturedCount: capturedTokens.length,
      reachedCenter: reachedCenter,
      grantsExtraTurn: grantsExtraTurn,
      gameFinished: gameFinished,
      animationPaths: animationPaths,
      animationDelays: animationDelays,
    );
  }

  List<BoardCell> _animationPathForMove(
    TokenState token,
    int targetPathIndex,
  ) {
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final fromIndex = token.isAtStart ? -1 : token.pathIndex;
    final waypoints = <BoardCell>[];

    if (fromIndex < 0) {
      waypoints.add(IstoBoardPaths.homeCellForPlayer(token.playerIndex));
    } else {
      waypoints.add(path[fromIndex]);
    }

    if (targetPathIndex < fromIndex) {
      for (var index = fromIndex + 1;
          index < IstoBoardPaths.outerPathLength;
          index++) {
        waypoints.add(path[index]);
      }
      for (var index = 0; index <= targetPathIndex; index++) {
        waypoints.add(path[index]);
      }
    } else {
      for (var index = fromIndex + 1; index <= targetPathIndex; index++) {
        waypoints.add(path[index]);
      }
    }

    return waypoints;
  }

  List<BoardCell> _animationPathToStart(TokenState token) {
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final home = IstoBoardPaths.homeCellForPlayer(token.playerIndex);

    if (token.isAtStart) return [home];

    final waypoints = <BoardCell>[path[token.pathIndex]];
    for (var index = token.pathIndex - 1; index >= 0; index--) {
      waypoints.add(path[index]);
    }
    waypoints.add(home);
    return waypoints;
  }

  List<TokenState> _legalMovesFor(int playerIndex, int roll) {
    final moves = <TokenState>[];
    for (final token in _tokens) {
      if (token.playerIndex != playerIndex || token.isFinished) continue;
      final targetPathIndex = _targetPathIndex(token, roll);
      if (targetPathIndex == null) continue;
      final destination = IstoBoardPaths.pathForPlayer(
        playerIndex,
      )[targetPathIndex];
      if (_canLandOn(token, destination)) {
        moves.add(token);
      }
    }
    return moves;
  }

  int? _targetPathIndex(TokenState token, int steps) {
    if (token.isFinished) return null;

    final currentIndex = token.isAtStart ? -1 : token.pathIndex;
    final proposedIndex = currentIndex + steps;
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final alreadyInside = currentIndex >= IstoBoardPaths.outerPathLength;
    final canEnterInner =
        playerStates[token.playerIndex].hasKilledOpponent || alreadyInside;

    if (!canEnterInner && proposedIndex >= IstoBoardPaths.outerPathLength) {
      return proposedIndex % IstoBoardPaths.outerPathLength;
    }
    if (proposedIndex >= path.length) return null;
    return proposedIndex;
  }

  bool _canLandOn(TokenState movingToken, BoardCell destination) {
    // Landing is always allowed; capture strength is enforced in _tokensToCapture.
    return true;
  }

  List<TokenState> _tokensToCapture(
    TokenState movingToken,
    BoardCell destination,
  ) {
    if (IstoBoardPaths.isSafeCell(destination) ||
        destination == IstoBoardPaths.centerCell) {
      return const [];
    }

    final incomingStrength =
        _activeStackStrength(
          movingToken.playerIndex,
          destination,
          excludingTokenId: movingToken.id,
        ) +
        1;
    final captured = <TokenState>[];

    for (
      var playerIndex = 0;
      playerIndex < playerStates.length;
      playerIndex++
    ) {
      if (playerIndex == movingToken.playerIndex) continue;
      final opponentTokens = _activeTokensAtCell(playerIndex, destination);
      if (opponentTokens.isEmpty) continue;
      if (opponentTokens.length <= incomingStrength) {
        captured.addAll(opponentTokens);
      }
    }

    return captured;
  }

  int _activeStackStrength(
    int playerIndex,
    BoardCell cell, {
    int? excludingTokenId,
  }) {
    return _activeTokensAtCell(
      playerIndex,
      cell,
    ).where((token) => token.id != excludingTokenId).length;
  }

  List<TokenState> _activeTokensAtCell(int playerIndex, BoardCell cell) {
    return [
      for (final token in _tokens)
        if (token.playerIndex == playerIndex &&
            !token.isAtStart &&
            !token.isFinished &&
            cellForToken(token) == cell)
          token,
    ];
  }

  void _handleNoLegalMove(int playerIndex, int value) {
    pendingRoll = null;
    legalTokenIds = {};

    if (_rollGrantsExtraTurn(value)) return;

    _advanceTurn();
  }

  void _advanceTurn() {
    final turnIndex = turnOrder.indexOf(currentPlayerIndex);
    currentPlayerIndex = turnOrder[(turnIndex + 1) % turnOrder.length];
  }

  void _resetKillPermissionIfAllAtStart(int playerIndex) {
    final allAtStart = _tokens
        .where((token) => token.playerIndex == playerIndex)
        .every((token) => token.isAtStart);
    if (allAtStart) {
      playerStates[playerIndex].hasKilledOpponent = false;
    }
  }

  bool _rollGrantsExtraTurn(int value) => value == 4 || value == 8;

  TokenState? _tokenById(int tokenId) {
    for (final token in _tokens) {
      if (token.id == tokenId) return token;
    }
    return null;
  }
}
