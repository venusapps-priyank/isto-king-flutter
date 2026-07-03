import 'package:isto_king/data/game_constants.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
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
  });

  final int capturedCount;
  final bool reachedCenter;
  final bool grantsExtraTurn;
  final bool gameFinished;
  final Map<int, List<BoardCell>> animationPaths;
}

class GameTurnController {
  GameTurnController() {
    statusMessage = '${_playerName(currentPlayerIndex)} rolls first';
  }

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
  late String statusMessage;

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
      return;
    }

    statusMessage =
        '${_playerName(playerIndex)} rolled $value. Tap a highlighted token';
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
    final animationPaths = <int, List<BoardCell>>{
      token.id: _animationPathForMove(token, targetPathIndex),
      for (final captured in capturedTokens)
        captured.id: [
          cellForToken(captured),
          IstoBoardPaths.homeCellForPlayer(captured.playerIndex),
        ],
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
      statusMessage = '${_playerName(token.playerIndex)} wins the game';
    } else if (grantsExtraTurn) {
      statusMessage = _extraTurnMessage(
        token.playerIndex,
        roll,
        capturedTokens.length,
        reachedCenter,
      );
    } else {
      final movedPlayerName = _playerName(token.playerIndex);
      _advanceTurn();
      statusMessage =
          '$movedPlayerName moved $roll. ${_playerName(currentPlayerIndex)} rolls next';
    }

    return MoveResolution(
      capturedCount: capturedTokens.length,
      reachedCenter: reachedCenter,
      grantsExtraTurn: grantsExtraTurn,
      gameFinished: gameFinished,
      animationPaths: animationPaths,
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
    if (IstoBoardPaths.isSafeCell(destination) ||
        destination == IstoBoardPaths.centerCell) {
      return true;
    }

    final incomingStrength =
        _activeStackStrength(
          movingToken.playerIndex,
          destination,
          excludingTokenId: movingToken.id,
        ) +
        1;

    for (
      var playerIndex = 0;
      playerIndex < playerStates.length;
      playerIndex++
    ) {
      if (playerIndex == movingToken.playerIndex) continue;
      final opponentStrength = _activeStackStrength(playerIndex, destination);
      if (opponentStrength > incomingStrength) return false;
    }
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

    if (_rollGrantsExtraTurn(value)) {
      statusMessage =
          '${_playerName(playerIndex)} rolled $value with no move. Roll again';
      return;
    }

    final skippedPlayerName = _playerName(playerIndex);
    _advanceTurn();
    statusMessage =
        '$skippedPlayerName rolled $value with no move. ${_playerName(currentPlayerIndex)} rolls next';
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

  String _extraTurnMessage(
    int playerIndex,
    int roll,
    int capturedCount,
    bool reachedCenter,
  ) {
    if (reachedCenter) {
      return '${_playerName(playerIndex)} reached home. Roll again';
    }
    if (capturedCount > 0) {
      return '${_playerName(playerIndex)} captured $capturedCount. Roll again';
    }
    return '${_playerName(playerIndex)} rolled $roll. Roll again';
  }

  TokenState? _tokenById(int tokenId) {
    for (final token in _tokens) {
      if (token.id == tokenId) return token;
    }
    return null;
  }

  String _playerName(int playerIndex) => gamePlayers[playerIndex].name;
}
