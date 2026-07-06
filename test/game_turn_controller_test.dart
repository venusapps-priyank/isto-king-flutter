import 'package:flutter_test/flutter_test.dart';
import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/logic/cowrie_logic.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
import 'package:isto_king/features/game/logic/move_animation_timing.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/token_state.dart';

void main() {
  group('CowrieLogic', () {
    test('maps open shells to ISTO move values', () {
      expect(CowrieLogic.calculateIstoValue([true, false, false, false]), 1);
      expect(CowrieLogic.calculateIstoValue([true, true, false, false]), 2);
      expect(CowrieLogic.calculateIstoValue([true, true, true, false]), 3);
      expect(CowrieLogic.calculateIstoValue([true, true, true, true]), 4);
      expect(CowrieLogic.calculateIstoValue([false, false, false, false]), 8);
    });
  });

  group('GameTurnController', () {
    test('uses the reversed player turn order', () {
      final controller = GameTurnController();
      final blueToken = tokenFor(controller, 3, 0);

      expect(controller.currentPlayerIndex, 3);

      controller.handleRollComplete(3, 1);
      controller.moveToken(blueToken.id);

      expect(controller.currentPlayerIndex, 1);
    });

    test('auto-selects one of several equivalent home tokens', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;

      controller.handleRollComplete(0, 1);

      expect(controller.legalTokenIds, {0, 1, 2, 3});
      expect(controller.autoMoveTokenId, 0);
    });

    test('auto-selects the only playable token', () {
      final controller = GameTurnController()..currentPlayerIndex = 2;
      final yellowPath = IstoBoardPaths.pathForPlayer(2);
      final remainingYellow = tokenFor(controller, 2, 0);
      placeToken(remainingYellow, yellowPath.length - 2);
      for (var tokenIndex = 1; tokenIndex < 4; tokenIndex++) {
        finishToken(tokenFor(controller, 2, tokenIndex));
      }

      controller.handleRollComplete(2, 1);

      expect(controller.legalTokenIds, {remainingYellow.id});
      expect(controller.autoMoveTokenId, remainingYellow.id);
    });

    test('does not auto-select when multiple different moves are available', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final firstRed = tokenFor(controller, 0, 0);
      final secondRed = tokenFor(controller, 0, 1);
      placeToken(firstRed, 0);
      placeToken(secondRed, 2);
      finishToken(tokenFor(controller, 0, 2));
      finishToken(tokenFor(controller, 0, 3));

      controller.handleRollComplete(0, 1);

      expect(controller.legalTokenIds, {firstRed.id, secondRed.id});
      expect(controller.autoMoveTokenId, isNull);
    });

    test('inner paths enter center from each player home side', () {
      const finalCellsByPlayer = [
        BoardCell(2, 1), // Red enters from top.
        BoardCell(3, 2), // Green enters from right.
        BoardCell(1, 2), // Yellow enters from left.
        BoardCell(2, 3), // Blue enters from bottom.
      ];

      for (var playerIndex = 0;
          playerIndex < finalCellsByPlayer.length;
          playerIndex++) {
        final path = IstoBoardPaths.pathForPlayer(playerIndex);

        expect(path[path.length - 2], finalCellsByPlayer[playerIndex]);
        expect(path.last, IstoBoardPaths.centerCell);
      }
    });

    test('moves blue into the center from the blue home side', () {
      final controller = GameTurnController()..currentPlayerIndex = 3;
      final blueToken = tokenFor(controller, 3, 0);
      final bluePath = IstoBoardPaths.pathForPlayer(3);
      placeToken(blueToken, bluePath.length - 2);

      controller.handleRollComplete(3, 1);
      final result = controller.moveToken(blueToken.id);

      expect(
        result?.animationPaths[blueToken.id],
        [const BoardCell(2, 3), IstoBoardPaths.centerCell],
      );
      expect(blueToken.isFinished, isTrue);
    });

    test('keeps looping on the outer path before kill permission', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redToken = tokenFor(controller, 0, 0);
      placeToken(redToken, IstoBoardPaths.outerPathLength - 1);

      controller.handleRollComplete(0, 1);
      controller.moveToken(redToken.id);

      expect(redToken.pathIndex, 0);
      expect(redToken.isFinished, isFalse);
    });

    test('enters the inner path after kill permission', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redToken = tokenFor(controller, 0, 0);
      placeToken(redToken, IstoBoardPaths.outerPathLength - 1);
      controller.playerStates[0].hasKilledOpponent = true;

      controller.handleRollComplete(0, 1);
      controller.moveToken(redToken.id);

      expect(redToken.pathIndex, IstoBoardPaths.outerPathLength);
      expect(controller.cellForToken(redToken), const BoardCell(3, 1));
    });

    test('allows a single token to land on a two-token stack without capturing', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redPath = IstoBoardPaths.pathForPlayer(0);
      final destination = redPath[1];
      final redToken = tokenFor(controller, 0, 0);
      final firstGreen = tokenFor(controller, 1, 0);
      final secondGreen = tokenFor(controller, 1, 1);
      placeToken(redToken, 0);
      placeToken(firstGreen, pathIndexForCell(1, destination));
      placeToken(secondGreen, pathIndexForCell(1, destination));

      controller.handleRollComplete(0, 1);

      expect(controller.legalTokenIds, contains(redToken.id));

      final result = controller.moveToken(redToken.id);

      expect(result?.capturedCount, 0);
      expect(firstGreen.isAtStart, isFalse);
      expect(secondGreen.isAtStart, isFalse);
      expect(controller.cellForToken(redToken), destination);
    });

    test(
      'captures an equal opponent stack and resets their kill permission',
      () {
        final controller = GameTurnController()..currentPlayerIndex = 0;
        final redPath = IstoBoardPaths.pathForPlayer(0);
        final destination = redPath[1];
        final movingRed = tokenFor(controller, 0, 0);
        final stackedRed = tokenFor(controller, 0, 1);
        final firstGreen = tokenFor(controller, 1, 0);
        final secondGreen = tokenFor(controller, 1, 1);
        placeToken(movingRed, 0);
        placeToken(stackedRed, 1);
        placeToken(firstGreen, pathIndexForCell(1, destination));
        placeToken(secondGreen, pathIndexForCell(1, destination));
        controller.playerStates[1].hasKilledOpponent = true;

        controller.handleRollComplete(0, 1);
        final result = controller.moveToken(movingRed.id);

        expect(result?.capturedCount, 2);
        expect(firstGreen.isAtStart, isTrue);
        expect(secondGreen.isAtStart, isTrue);
        expect(controller.playerStates[0].hasKilledOpponent, isTrue);
        expect(controller.playerStates[1].hasKilledOpponent, isFalse);
        expect(controller.currentPlayerIndex, 0);
      },
    );

    test('does not capture tokens on any safe cell', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      const safeDestination = BoardCell(0, 2);
      final redToken = tokenFor(controller, 0, 0);
      final greenToken = tokenFor(controller, 1, 0);
      placeToken(redToken, pathIndexForCell(0, const BoardCell(0, 1)));
      placeToken(greenToken, pathIndexForCell(1, safeDestination));

      controller.handleRollComplete(0, 1);
      final result = controller.moveToken(redToken.id);

      expect(result?.capturedCount, 0);
      expect(greenToken.isAtStart, isFalse);
      expect(controller.cellForToken(redToken), safeDestination);
      expect(controller.cellForToken(greenToken), safeDestination);
    });

    test('keeps the same player after rolling four', () {
      final controller = GameTurnController()..currentPlayerIndex = 2;
      final yellowToken = tokenFor(controller, 2, 0);

      controller.handleRollComplete(2, 4);
      controller.moveToken(yellowToken.id);

      expect(controller.currentPlayerIndex, 2);
      expect(controller.pendingRoll, isNull);
    });

    test('discards an unplayable eight and lets the same player roll again', () {
      final controller = GameTurnController()..currentPlayerIndex = 2;
      final yellowPath = IstoBoardPaths.pathForPlayer(2);
      final remainingYellow = tokenFor(controller, 2, 0);
      placeToken(remainingYellow, yellowPath.length - 2);
      for (var tokenIndex = 1; tokenIndex < 4; tokenIndex++) {
        finishToken(tokenFor(controller, 2, tokenIndex));
      }

      final result = controller.handleRollComplete(2, 8);

      expect(result?.hasLegalMove, isFalse);
      expect(result?.grantsExtraTurn, isTrue);
      expect(result?.discarded, isTrue);
      expect(remainingYellow.pathIndex, yellowPath.length - 2);
      expect(controller.pendingRoll, isNull);
      expect(controller.legalTokenIds, isEmpty);
      expect(controller.lastRolls[2], isNull);
      expect(controller.currentPlayerIndex, 2);
      expect(controller.canRoll(2), isTrue);
    });

    test('ranks a finished player and continues the match', () {
      final controller = GameTurnController();

      final result = finishPlayerByMovingFinalToken(controller, 1);

      expect(result?.gameFinished, isFalse);
      expect(controller.rankedPlayerIndexes, [1]);
      expect(controller.rankForPlayer(1), 1);
      expect(controller.winnerIndex, 1);
      expect(controller.currentPlayerIndex, 0);
      expect(controller.canRoll(0), isTrue);
      expect(controller.canRoll(1), isFalse);
    });

    test('skips ranked players in the turn order', () {
      final controller = GameTurnController();
      finishPlayerByMovingFinalToken(controller, 1);
      controller.currentPlayerIndex = 3;
      final blueToken = tokenFor(controller, 3, 0);

      controller.handleRollComplete(3, 1);
      controller.moveToken(blueToken.id);

      expect(controller.currentPlayerIndex, 0);
    });

    test('stops the match after the first three players are ranked', () {
      final controller = GameTurnController();

      finishPlayerByMovingFinalToken(controller, 1);
      finishPlayerByMovingFinalToken(controller, 0);
      final result = finishPlayerByMovingFinalToken(controller, 2);

      expect(result?.gameFinished, isTrue);
      expect(controller.rankedPlayerIndexes, [1, 0, 2]);
      expect(controller.rankForPlayer(1), 1);
      expect(controller.rankForPlayer(0), 2);
      expect(controller.rankForPlayer(2), 3);
      expect(controller.rankForPlayer(3), isNull);
      expect(controller.isGameOver, isTrue);
      expect(controller.canRoll(3), isFalse);
    });

    test('animates captured tokens back along the reverse path', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redPath = IstoBoardPaths.pathForPlayer(0);
      final destination = redPath[2];
      final movingRed = tokenFor(controller, 0, 0);
      final capturedGreen = tokenFor(controller, 1, 0);
      final greenPath = IstoBoardPaths.pathForPlayer(1);
      final greenPathIndex = pathIndexForCell(1, destination);
      placeToken(movingRed, 1);
      placeToken(capturedGreen, greenPathIndex);

      controller.handleRollComplete(0, 1);
      final result = controller.moveToken(movingRed.id);

      final capturePath = result!.animationPaths[capturedGreen.id]!;
      expect(capturePath.first, greenPath[greenPathIndex]);
      expect(capturePath.last, IstoBoardPaths.homeCellForPlayer(1));
      expect(
        capturePath,
        [
          for (var index = greenPathIndex; index >= 0; index--)
            greenPath[index],
          IstoBoardPaths.homeCellForPlayer(1),
        ],
      );
    });

    test('delays captured token animation until killer arrives', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redPath = IstoBoardPaths.pathForPlayer(0);
      final destination = redPath[2];
      final movingRed = tokenFor(controller, 0, 0);
      final capturedGreen = tokenFor(controller, 1, 0);
      final greenPathIndex = pathIndexForCell(1, destination);
      placeToken(movingRed, 1);
      placeToken(capturedGreen, greenPathIndex);

      controller.handleRollComplete(0, 1);
      final result = controller.moveToken(movingRed.id);

      final killerPath = result!.animationPaths[movingRed.id]!;
      final killerDuration = MoveAnimationTiming.durationForPath(killerPath);
      expect(result.animationDelays[capturedGreen.id], killerDuration);
    });
  });
}

TokenState tokenFor(
  GameTurnController controller,
  int playerIndex,
  int tokenIndex,
) {
  return controller.tokens.firstWhere(
    (token) =>
        token.playerIndex == playerIndex && token.tokenIndex == tokenIndex,
  );
}

void placeToken(TokenState token, int pathIndex) {
  token
    ..isAtStart = false
    ..isFinished = false
    ..pathIndex = pathIndex;
}

void finishToken(TokenState token) {
  token
    ..isAtStart = false
    ..isFinished = true
    ..pathIndex = IstoBoardPaths.pathForPlayer(token.playerIndex).length - 1;
}

MoveResolution? finishPlayerByMovingFinalToken(
  GameTurnController controller,
  int playerIndex,
) {
  controller.currentPlayerIndex = playerIndex;
  final path = IstoBoardPaths.pathForPlayer(playerIndex);
  final movingToken = tokenFor(controller, playerIndex, 0);
  placeToken(movingToken, path.length - 2);
  for (var tokenIndex = 1; tokenIndex < 4; tokenIndex++) {
    finishToken(tokenFor(controller, playerIndex, tokenIndex));
  }

  controller.handleRollComplete(playerIndex, 1);
  return controller.moveToken(movingToken.id);
}

int pathIndexForCell(int playerIndex, BoardCell cell) {
  return IstoBoardPaths.pathForPlayer(
    playerIndex,
  ).indexWhere((candidate) => candidate == cell);
}
