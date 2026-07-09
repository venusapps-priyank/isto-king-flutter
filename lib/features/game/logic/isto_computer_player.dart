import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/token_state.dart';

class IstoComputerPlayer {
  bool shouldJoinPair(
    GameTurnController controller,
    TokenPairCandidate candidate,
  ) {
    final roll = controller.pendingRoll;
    if (roll == null) return false;

    final pairSteps = GameTurnController.pairMoveStepsForRoll(roll);
    if (pairSteps == null) return false;

    final token = controller.tokens.firstWhere(
      (candidateToken) => candidateToken.id == candidate.tokenIds.first,
    );
    final targetIndex = _targetPathIndexFor(
      controller,
      token,
      pairSteps,
    );
    if (targetIndex == null) return false;

    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final destination = path[targetIndex];
    return _captureCount(controller, token, destination) > 0 ||
        targetIndex >= path.length - 1;
  }

  int? chooseTokenId(GameTurnController controller) {
    final autoMove = controller.autoMoveTokenId;
    if (autoMove != null) return autoMove;

    final legalIds = controller.legalTokenIds.toList()..sort();
    if (legalIds.isEmpty) return null;
    if (legalIds.length == 1) return legalIds.first;

    var bestId = legalIds.first;
    var bestScore = -0x7fffffff;
    for (final tokenId in legalIds) {
      final score = _scoreTokenMove(controller, tokenId);
      if (score > bestScore) {
        bestScore = score;
        bestId = tokenId;
      }
    }
    return bestId;
  }

  int _scoreTokenMove(GameTurnController controller, int tokenId) {
    final roll = controller.pendingRoll;
    if (roll == null) return 0;

    final token = controller.tokens.firstWhere(
      (candidate) => candidate.id == tokenId,
    );
    final moveSteps = token.isPaired
        ? GameTurnController.pairMoveStepsForRoll(roll) ?? roll
        : roll;
    final targetIndex = _targetPathIndexFor(controller, token, moveSteps);
    if (targetIndex == null) return -1000;

    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final destination = path[targetIndex];
    var score = targetIndex * 8;

    if (token.isAtStart) score += 60;
    if (targetIndex >= path.length - 1) score += 250;

    final captures = _captureCount(controller, token, destination);
    score += captures * 120;

    if (IstoBoardPaths.isSafeCell(destination)) {
      score += 10;
    }

    return score;
  }

  int _captureCount(
    GameTurnController controller,
    TokenState movingToken,
    BoardCell destination,
  ) {
    if (IstoBoardPaths.isSafeCell(destination) ||
        destination == IstoBoardPaths.centerCell) {
      return 0;
    }

    final movingGroup = _movingGroup(controller, movingToken);
    final incomingStrength = movingGroup.length;
    var captures = 0;

    for (final token in controller.tokens) {
      if (token.playerIndex == movingToken.playerIndex ||
          token.isAtStart ||
          token.isFinished) {
        continue;
      }
      if (controller.cellForToken(token) != destination) continue;

      final stack = controller.tokens
          .where(
            (candidate) =>
                candidate.playerIndex == token.playerIndex &&
                !candidate.isAtStart &&
                !candidate.isFinished &&
                controller.cellForToken(candidate) == destination,
          )
          .length;
      if (stack <= incomingStrength) {
        captures += stack;
      }
    }

    return captures;
  }

  List<TokenState> _movingGroup(
    GameTurnController controller,
    TokenState token,
  ) {
    final pairedId = token.pairedTokenId;
    if (pairedId == null) return [token];

    final partner = controller.tokens
        .where((candidate) => candidate.id == pairedId)
        .firstOrNull;
    if (partner == null ||
        partner.pairedTokenId != token.id ||
        partner.playerIndex != token.playerIndex ||
        controller.cellForToken(partner) != controller.cellForToken(token)) {
      return [token];
    }

    return [token, partner];
  }

  int? _targetPathIndexFor(
    GameTurnController controller,
    TokenState token,
    int moveSteps,
  ) {
    if (token.isFinished) return null;

    final currentIndex = token.isAtStart ? -1 : token.pathIndex;
    final proposedIndex = currentIndex + moveSteps;
    final path = IstoBoardPaths.pathForPlayer(token.playerIndex);
    final alreadyInside = currentIndex >= IstoBoardPaths.outerPathLength;
    final canEnterInner =
        controller.innerPathAccess[token.playerIndex] || alreadyInside;

    if (!canEnterInner && proposedIndex >= IstoBoardPaths.outerPathLength) {
      return proposedIndex % IstoBoardPaths.outerPathLength;
    }
    if (proposedIndex >= path.length) return null;
    return proposedIndex;
  }
}
