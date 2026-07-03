import 'package:flutter_test/flutter_test.dart';
import 'package:isto_king/features/game/controllers/game_turn_controller.dart';
import 'package:isto_king/features/game/logic/cowrie_logic.dart';
import 'package:isto_king/features/game/logic/isto_board_paths.dart';
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

    test('blocks a single token from killing a two-token stack', () {
      final controller = GameTurnController()..currentPlayerIndex = 0;
      final redPath = IstoBoardPaths.pathForPlayer(0);
      final destination = redPath[1];
      final redToken = tokenFor(controller, 0, 0);
      placeToken(redToken, 0);
      placeToken(tokenFor(controller, 1, 0), pathIndexForCell(1, destination));
      placeToken(tokenFor(controller, 1, 1), pathIndexForCell(1, destination));

      controller.handleRollComplete(0, 1);

      expect(controller.legalTokenIds, isNot(contains(redToken.id)));
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

int pathIndexForCell(int playerIndex, BoardCell cell) {
  return IstoBoardPaths.pathForPlayer(
    playerIndex,
  ).indexWhere((candidate) => candidate == cell);
}
