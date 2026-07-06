import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isto_king/app/isto_king_app.dart';
import 'package:isto_king/features/game/models/token_state.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';
import 'package:isto_king/features/game/widgets/game_board.dart';
import 'package:isto_king/features/game/widgets/game_token.dart';
import 'package:isto_king/features/game/widgets/player_card.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(430, 932)]) {
    testWidgets('Isto board screen fits ${size.width}x${size.height}', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const IstoKingApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Rammohan'), findsOneWidget);
      expect(find.text('Chandrakishore'), findsOneWidget);
      expect(find.text('Aaradhya'), findsOneWidget);
      expect(find.text('Shaurya'), findsOneWidget);
      expect(find.text('Current Turn:'), findsNothing);
      expect(find.text('120'), findsOneWidget);

      final boardRect = tester.getRect(find.byType(GameBoard));
      expect(GameBoardPainter.gridCount, 5);
      expect(GameBoardPainter.playerHomes, hasLength(4));
      for (final home in GameBoardPainter.playerHomes) {
        expect(home.arrowCol, greaterThanOrEqualTo(0));
        expect(home.arrowCol, lessThan(GameBoardPainter.gridCount));
        expect(home.arrowRow, greaterThanOrEqualTo(0));
        expect(home.arrowRow, lessThan(GameBoardPainter.gridCount));
        expect(home.col, inInclusiveRange(0, GameBoardPainter.gridCount - 1));
        expect(home.row, inInclusiveRange(0, GameBoardPainter.gridCount - 1));
        final columnDistance = (home.arrowCol - home.col).abs();
        final rowDistance = (home.arrowRow - home.row).abs();
        expect(columnDistance + rowDistance, 1);
      }
      expect(boardRect.width, closeTo(boardRect.height, 0.01));
      expect(boardRect.center.dx, closeTo(size.width / 2, 1));

      final root = Rect.fromLTWH(0, 0, size.width, size.height);
      for (final widget in find.byType(PlayerCard).evaluate()) {
        final rect = tester.getRect(find.byWidget(widget.widget));
        expect(root.contains(rect.topLeft), isTrue);
        expect(root.contains(rect.bottomRight), isTrue);
      }
    });
  }

  testWidgets('Isto board passes inner path access to painter', (tester) async {
    const innerPathAccess = [true, false, true, false];

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.square(
          dimension: 320,
          child: GameBoard(
            tokens: [],
            movableTokenIds: {},
            innerPathAccess: innerPathAccess,
          ),
        ),
      ),
    );

    final customPaint = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .singleWhere((widget) => widget.painter is GameBoardPainter);
    final painter = customPaint.painter as GameBoardPainter;

    expect(painter.innerPathAccess, innerPathAccess);
  });

  testWidgets('player card shows finish rank badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 240,
          height: 100,
          child: PlayerCard(
            name: 'Chandrakishore',
            color: Colors.green,
            avatarAsset: 'assets/avatar/avatar-f-1.png',
            finishRank: 1,
          ),
        ),
      ),
    );

    expect(find.text('1st'), findsOneWidget);
  });

  testWidgets('finished center tokens fan out inside their color triangles', (
    tester,
  ) async {
    final tokens = [
      TokenState(
        playerIndex: 1,
        tokenIndex: 0,
        isAtStart: false,
        isFinished: true,
      ),
      TokenState(
        playerIndex: 1,
        tokenIndex: 1,
        isAtStart: false,
        isFinished: true,
      ),
      TokenState(
        playerIndex: 1,
        tokenIndex: 2,
        isAtStart: false,
        isFinished: true,
      ),
      TokenState(
        playerIndex: 2,
        tokenIndex: 0,
        isAtStart: false,
        isFinished: true,
      ),
      TokenState(
        playerIndex: 2,
        tokenIndex: 1,
        isAtStart: false,
        isFinished: true,
      ),
      TokenState(
        playerIndex: 0,
        tokenIndex: 0,
        isAtStart: false,
        isFinished: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 500,
          child: GameBoard(tokens: tokens, movableTokenIds: const {}),
        ),
      ),
    );

    final boardRect = tester.getRect(find.byType(GameBoard));
    final shortest = boardRect.shortestSide;
    final boardSquare = Rect.fromCenter(
      center: boardRect.center,
      width: shortest,
      height: shortest,
    ).deflate(1);
    final inner = boardSquare.deflate(shortest * 0.032);
    final cellSize = inner.width / GameBoardPainter.gridCount;
    final centerCell = Rect.fromLTWH(
      inner.left + cellSize * 2,
      inner.top + cellSize * 2,
      cellSize,
      cellSize,
    );

    List<Offset> centersForPlayer(String playerName) {
      final playerTokens = find.byWidgetPredicate(
        (widget) =>
            widget is GameToken &&
            widget.semanticLabel.startsWith('$playerName token'),
      );

      return [
        for (final element in playerTokens.evaluate())
          tester.getRect(find.byWidget(element.widget)).center,
      ];
    }

    final greenCenters = centersForPlayer('Chandrakishore');
    final yellowCenters = centersForPlayer('Aaradhya');

    expect(greenCenters, hasLength(3));
    expect(yellowCenters, hasLength(2));
    expect(greenCenters.toSet(), hasLength(3));
    expect(yellowCenters.toSet(), hasLength(2));

    for (final center in greenCenters) {
      expect(center.dx, greaterThan(centerCell.center.dx));
    }
    for (final center in yellowCenters) {
      expect(center.dx, lessThan(centerCell.center.dx));
    }
  });
}
