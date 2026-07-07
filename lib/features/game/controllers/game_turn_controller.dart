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
    this.pairCandidate,
  });

  final int capturedCount;
  final bool reachedCenter;
  final bool grantsExtraTurn;
  final bool gameFinished;
  final Map<int, List<BoardCell>> animationPaths;
  final Map<int, Duration> animationDelays;
  final TokenPairCandidate? pairCandidate;
}

class TokenPairCandidate {
  const TokenPairCandidate({required this.playerIndex, required this.tokenIds});

  final int playerIndex;
  final List<int> tokenIds;
}

class RollResolution {
  const RollResolution({
    required this.value,
    required this.hasLegalMove,
    required this.grantsExtraTurn,
    required this.discarded,
  });

  final int value;
  final bool hasLegalMove;
  final bool grantsExtraTurn;
  final bool discarded;
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
  final List<int> _rankedPlayerIndexes = [];

  int? pendingRoll;
  Set<int> legalTokenIds = {};

  List<TokenState> get tokens => List<TokenState>.unmodifiable(_tokens);

  List<int> get rankedPlayerIndexes =>
      List<int>.unmodifiable(_rankedPlayerIndexes);

  int? get winnerIndex =>
      _rankedPlayerIndexes.isEmpty ? null : _rankedPlayerIndexes.first;

  bool get isGameOver => _rankedPlayerIndexes.length >= 3;

  List<bool> get innerPathAccess => List<bool>.unmodifiable(
    playerStates.map((state) => state.hasKilledOpponent),
  );

  int? rankForPlayer(int playerIndex) {
    final rankIndex = _rankedPlayerIndexes.indexOf(playerIndex);
    if (rankIndex < 0 || rankIndex >= 3) return null;
    return rankIndex + 1;
  }

  int? get autoMoveTokenId {
    final legalTokens = _legalTokensSorted();
    if (legalTokens.isEmpty) return null;
    if (legalTokens.length == 1) return legalTokens.first.id;

    final firstSignature = _moveSignatureFor(legalTokens.first);
    if (firstSignature == null) return null;

    for (final token in legalTokens.skip(1)) {
      if (_moveSignatureFor(token) != firstSignature) return null;
    }
    return legalTokens.first.id;
  }

  bool get hasPendingMove => pendingRoll != null && legalTokenIds.isNotEmpty;

  static int? pairMoveStepsForRoll(int roll) {
    return switch (roll) {
      2 => 1,
      4 => 2,
      8 => 4,
      _ => null,
    };
  }

  bool canRoll(int playerIndex) {
    return !isGameOver &&
        rankForPlayer(playerIndex) == null &&
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

  RollResolution? handleRollComplete(int playerIndex, int value) {
    if (!canRoll(playerIndex)) return null;

    lastRolls[playerIndex] = value;
    pendingRoll = value;
    legalTokenIds = _legalMovesFor(
      playerIndex,
      value,
    ).map((token) => token.id).toSet();

    if (legalTokenIds.isEmpty) {
      final grantsExtraTurn = _rollGrantsExtraTurn(value);
      _handleNoLegalMove(playerIndex, value);
      return RollResolution(
        value: value,
        hasLegalMove: false,
        grantsExtraTurn: grantsExtraTurn,
        discarded: true,
      );
    }

    return RollResolution(
      value: value,
      hasLegalMove: true,
      grantsExtraTurn: _rollGrantsExtraTurn(value),
      discarded: false,
    );
  }

  MoveResolution? moveToken(int tokenId) {
    final roll = pendingRoll;
    if (roll == null || !legalTokenIds.contains(tokenId)) return null;

    final token = _tokenById(tokenId);
    if (token == null || token.playerIndex != currentPlayerIndex) return null;

    final targetPathIndex = _targetPathIndex(token, roll);
    if (targetPathIndex == null) return null;

    final movingTokens = _moveGroupForToken(token);
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final destination = path[targetPathIndex];
    final capturedTokens = _tokensToCapture(token, destination, movingTokens);
    final killerPath = _animationPathForMove(token, targetPathIndex);
    final animationPaths = <int, List<BoardCell>>{
      for (final movingToken in movingTokens) movingToken.id: killerPath,
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

    for (final movingToken in movingTokens) {
      movingToken
        ..isAtStart = false
        ..pathIndex = targetPathIndex
        ..isFinished = targetPathIndex == path.length - 1;
    }

    if (_shouldUnlockPairAt(destination)) {
      for (final movingToken in movingTokens) {
        movingToken.unpair();
      }
    }

    if (capturedTokens.isNotEmpty) {
      playerStates[token.playerIndex].hasKilledOpponent = true;
    }
    for (final capturedToken in capturedTokens) {
      _resetKillPermissionIfAllAtStart(capturedToken.playerIndex);
    }

    final reachedCenter = movingTokens.any(
      (movingToken) => movingToken.isFinished,
    );
    final grantsExtraTurn =
        _rollGrantsExtraTurn(roll) ||
        capturedTokens.isNotEmpty ||
        reachedCenter;
    final playerFinished = _tokens
        .where((candidate) => candidate.playerIndex == token.playerIndex)
        .every((candidate) => candidate.isFinished);

    pendingRoll = null;
    legalTokenIds = {};

    if (playerFinished) {
      _rankPlayerIfNeeded(token.playerIndex);
      if (!isGameOver) {
        _advanceTurn();
      }
    } else if (!grantsExtraTurn) {
      _advanceTurn();
    }

    final pairCandidate = movingTokens.length == 1
        ? _pairCandidateAt(token.playerIndex, destination)
        : null;

    return MoveResolution(
      capturedCount: capturedTokens.length,
      reachedCenter: reachedCenter,
      grantsExtraTurn: grantsExtraTurn,
      gameFinished: isGameOver,
      animationPaths: animationPaths,
      animationDelays: animationDelays,
      pairCandidate: pairCandidate,
    );
  }

  bool lockTokenPair(List<int> tokenIds) {
    if (tokenIds.length != 2) return false;

    final first = _tokenById(tokenIds[0]);
    final second = _tokenById(tokenIds[1]);
    if (first == null || second == null) return false;
    if (first.playerIndex != second.playerIndex) return false;
    if (first.isAtStart ||
        second.isAtStart ||
        first.isFinished ||
        second.isFinished) {
      return false;
    }
    if (first.isPaired || second.isPaired) return false;
    if (cellForToken(first) != cellForToken(second)) return false;
    if (_shouldUnlockPairAt(cellForToken(first))) return false;

    first.pairWith(second);
    return true;
  }

  List<BoardCell> _animationPathForMove(TokenState token, int targetPathIndex) {
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final fromIndex = token.isAtStart ? -1 : token.pathIndex;
    final waypoints = <BoardCell>[];

    if (fromIndex < 0) {
      waypoints.add(IstoBoardPaths.homeCellForPlayer(token.playerIndex));
    } else {
      waypoints.add(path[fromIndex]);
    }

    if (targetPathIndex < fromIndex) {
      for (
        var index = fromIndex + 1;
        index < IstoBoardPaths.outerPathLength;
        index++
      ) {
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

  List<TokenState> _legalTokensSorted() {
    final legalTokens = [
      for (final token in _tokens)
        if (legalTokenIds.contains(token.id)) token,
    ];
    legalTokens.sort((first, second) => first.id.compareTo(second.id));
    return legalTokens;
  }

  ({int sourcePathIndex, int targetPathIndex, BoardCell destination})?
  _moveSignatureFor(TokenState token) {
    final roll = pendingRoll;
    if (roll == null) return null;

    final targetPathIndex = _targetPathIndex(token, roll);
    if (targetPathIndex == null) return null;

    return (
      sourcePathIndex: token.isAtStart ? -1 : token.pathIndex,
      targetPathIndex: targetPathIndex,
      destination: IstoBoardPaths.pathForPlayer(
        token.playerIndex,
      )[targetPathIndex],
    );
  }

  int? _targetPathIndex(TokenState token, int steps) {
    if (token.isFinished) return null;
    final moveSteps = _moveStepsForRoll(token, steps);
    if (moveSteps == null) return null;

    final currentIndex = token.isAtStart ? -1 : token.pathIndex;
    final proposedIndex = currentIndex + moveSteps;
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
    List<TokenState> movingTokens,
  ) {
    if (IstoBoardPaths.isSafeCell(destination) ||
        destination == IstoBoardPaths.centerCell) {
      return const [];
    }

    final incomingStrength =
        _activeStackStrength(
          movingToken.playerIndex,
          destination,
          excludingTokenIds: movingTokens.map((token) => token.id).toSet(),
        ) +
        movingTokens.length;
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
    Set<int> excludingTokenIds = const {},
  }) {
    return _activeTokensAtCell(
      playerIndex,
      cell,
    ).where((token) => !excludingTokenIds.contains(token.id)).length;
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
    lastRolls[playerIndex] = null;

    if (_rollGrantsExtraTurn(value)) return;

    _advanceTurn();
  }

  void _advanceTurn() {
    final turnIndex = turnOrder.indexOf(currentPlayerIndex);
    for (var offset = 1; offset <= turnOrder.length; offset++) {
      final nextPlayer = turnOrder[(turnIndex + offset) % turnOrder.length];
      if (rankForPlayer(nextPlayer) == null) {
        currentPlayerIndex = nextPlayer;
        return;
      }
    }
  }

  void _rankPlayerIfNeeded(int playerIndex) {
    if (_rankedPlayerIndexes.contains(playerIndex) || isGameOver) return;
    _rankedPlayerIndexes.add(playerIndex);
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

  int? _moveStepsForRoll(TokenState token, int roll) {
    return token.isPaired ? pairMoveStepsForRoll(roll) : roll;
  }

  List<TokenState> _moveGroupForToken(TokenState token) {
    final pairedTokenId = token.pairedTokenId;
    if (pairedTokenId == null) return [token];

    final pairedToken = _tokenById(pairedTokenId);
    if (pairedToken == null ||
        pairedToken.pairedTokenId != token.id ||
        pairedToken.playerIndex != token.playerIndex ||
        pairedToken.isAtStart != token.isAtStart ||
        pairedToken.isFinished != token.isFinished ||
        pairedToken.pathIndex != token.pathIndex) {
      token.unpair();
      pairedToken?.unpair();
      return [token];
    }

    final tokens = [token, pairedToken]
      ..sort((first, second) => first.id.compareTo(second.id));
    return tokens;
  }

  TokenPairCandidate? _pairCandidateAt(int playerIndex, BoardCell cell) {
    if (_shouldUnlockPairAt(cell)) return null;

    final candidates =
        _activeTokensAtCell(
            playerIndex,
            cell,
          ).where((token) => !token.isPaired).toList()
          ..sort((first, second) => first.id.compareTo(second.id));
    if (candidates.length != 2) return null;

    return TokenPairCandidate(
      playerIndex: playerIndex,
      tokenIds: [for (final token in candidates) token.id],
    );
  }

  bool _shouldUnlockPairAt(BoardCell cell) {
    return IstoBoardPaths.isSafeCell(cell) || cell == IstoBoardPaths.centerCell;
  }

  TokenState? _tokenById(int tokenId) {
    for (final token in _tokens) {
      if (token.id == tokenId) return token;
    }
    return null;
  }
}
