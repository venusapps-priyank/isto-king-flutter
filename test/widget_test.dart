import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isto_king/app/isto_king_app.dart';
import 'package:isto_king/data/player_config.dart';
import 'package:isto_king/features/game/models/board_cell.dart';
import 'package:isto_king/features/game/models/token_state.dart';
import 'package:isto_king/features/game/painters/game_board_painter.dart';
import 'package:isto_king/features/game/widgets/game_board.dart';
import 'package:isto_king/features/game/widgets/game_token.dart';
import 'package:isto_king/features/game/widgets/path_animated_token.dart';
import 'package:isto_king/features/game/widgets/player_card.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(430, 932)]) {
    testWidgets('Isto board screen fits ${size.width}x${size.height}', (
      tester,
    ) async {
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
            players: gamePlayers,
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
        home: Center(
          child: SizedBox(
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
      ),
    );

    expect(find.text('1st'), findsOneWidget);
    expect(find.text('Finished'), findsOneWidget);
    final cardRect = tester.getRect(find.byType(PlayerCard));
    final badgeRect = tester.getRect(find.text('1st'));
    expect(badgeRect.center.dy, greaterThan(cardRect.center.dy));
    expect(badgeRect.center.dx, greaterThan(cardRect.left));
    expect(badgeRect.center.dx, lessThan(cardRect.right));
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
          child: GameBoard(
            players: gamePlayers,tokens: tokens, movableTokenIds: const {}),
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

  testWidgets('locked pair tokens slide into attached spacing', (tester) async {
    final firstToken = TokenState(
      playerIndex: 0,
      tokenIndex: 0,
      isAtStart: false,
      pathIndex: 1,
    );
    final secondToken = TokenState(
      playerIndex: 0,
      tokenIndex: 1,
      isAtStart: false,
      pathIndex: 1,
    );
    final tokens = [firstToken, secondToken];

    Future<void> pumpBoard() {
      return tester.pumpWidget(
        MaterialApp(
          home: SizedBox.square(
            dimension: 500,
            child: GameBoard(
              players: gamePlayers,
              tokens: tokens,
              movableTokenIds: const {},
            ),
          ),
        ),
      );
    }

    List<Offset> tokenCenters() {
      final tokenWidgets = find.byWidgetPredicate(
        (widget) =>
            widget is GameToken &&
            widget.semanticLabel.startsWith('Rammohan token'),
      );

      return [
        for (final element in tokenWidgets.evaluate())
          tester.getRect(find.byWidget(element.widget)).center,
      ]..sort((first, second) => first.dx.compareTo(second.dx));
    }

    await pumpBoard();
    final unpairedCenters = tokenCenters();
    final unpairedDistance = (unpairedCenters[1].dx - unpairedCenters[0].dx)
        .abs();

    firstToken.pairWith(secondToken);
    await pumpBoard();
    expect(find.byType(AnimatedPositioned), findsWidgets);
    await tester.pumpAndSettle();

    final pairedCenters = tokenCenters();
    final pairedDistance = (pairedCenters[1].dx - pairedCenters[0].dx).abs();

    expect(pairedDistance, lessThan(unpairedDistance * 0.55));
  });

  testWidgets('playable locked pair uses one shared highlight', (tester) async {
    final firstToken = TokenState(
      playerIndex: 0,
      tokenIndex: 0,
      isAtStart: false,
      pathIndex: 1,
    );
    final secondToken = TokenState(
      playerIndex: 0,
      tokenIndex: 1,
      isAtStart: false,
      pathIndex: 1,
    );
    firstToken.pairWith(secondToken);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 500,
          child: GameBoard(
            players: gamePlayers,
            tokens: [firstToken, secondToken],
            movableTokenIds: {firstToken.id, secondToken.id},
          ),
        ),
      ),
    );

    final tokenWidgets = tester.widgetList<GameToken>(
      find.byWidgetPredicate(
        (widget) =>
            widget is GameToken &&
            widget.semanticLabel.startsWith('Rammohan token'),
      ),
    );

    expect(tokenWidgets, hasLength(2));
    for (final tokenWidget in tokenWidgets) {
      expect(tokenWidget.isMovable, isTrue);
      expect(tokenWidget.showMovableHighlight, isFalse);
    }
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.runtimeType.toString() == '_PulsingPairMoveHighlight',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pair join prompt appears on the board near token cell', (
    tester,
  ) async {
    final firstToken = TokenState(
      playerIndex: 0,
      tokenIndex: 0,
      isAtStart: false,
      pathIndex: 1,
    );
    final secondToken = TokenState(
      playerIndex: 0,
      tokenIndex: 1,
      isAtStart: false,
      pathIndex: 1,
    );
    var joined = false;
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 500,
          child: GameBoard(
            players: gamePlayers,
            tokens: [firstToken, secondToken],
            movableTokenIds: {firstToken.id, secondToken.id},
            pairPromptTokenIds: [firstToken.id, secondToken.id],
            onJoinPairPrompt: () => joined = true,
            onDismissPairPrompt: () => dismissed = true,
          ),
        ),
      ),
    );

    expect(find.text('Pair?'), findsOneWidget);
    expect(find.text('Join'), findsOneWidget);
    expect(find.byTooltip('Play single'), findsOneWidget);

    await tester.tap(find.text('Join'));
    expect(joined, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    expect(dismissed, isTrue);
  });

  testWidgets('locked pair stays attached with another token in same cell', (
    tester,
  ) async {
    final firstToken = TokenState(
      playerIndex: 0,
      tokenIndex: 0,
      isAtStart: false,
      pathIndex: 1,
    );
    final secondToken = TokenState(
      playerIndex: 0,
      tokenIndex: 1,
      isAtStart: false,
      pathIndex: 1,
    );
    final thirdToken = TokenState(
      playerIndex: 0,
      tokenIndex: 2,
      isAtStart: false,
      pathIndex: 1,
    );
    firstToken.pairWith(secondToken);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 500,
          child: GameBoard(
            players: gamePlayers,
            tokens: [firstToken, secondToken, thirdToken],
            movableTokenIds: const {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boardRect = tester.getRect(find.byType(GameBoard));
    final shortest = boardRect.shortestSide;
    final boardSquare = Rect.fromCenter(
      center: boardRect.center,
      width: shortest,
      height: shortest,
    ).deflate(1);
    final inner = boardSquare.deflate(shortest * 0.032);
    final cellSize = inner.width / GameBoardPainter.gridCount;
    final targetCell = Rect.fromLTWH(inner.left, inner.top, cellSize, cellSize);

    Offset centerForToken(int tokenNumber) {
      final tokenFinder = find.byWidgetPredicate(
        (widget) =>
            widget is GameToken &&
            widget.semanticLabel == 'Rammohan token $tokenNumber',
      );
      return tester.getRect(tokenFinder).center;
    }

    Rect rectForToken(int tokenNumber) {
      final tokenFinder = find.byWidgetPredicate(
        (widget) =>
            widget is GameToken &&
            widget.semanticLabel == 'Rammohan token $tokenNumber',
      );
      return tester.getRect(tokenFinder);
    }

    final firstCenter = centerForToken(1);
    final secondCenter = centerForToken(2);
    final thirdCenter = centerForToken(3);
    final pairCenter = Offset.lerp(firstCenter, secondCenter, 0.5)!;

    expect((firstCenter - secondCenter).distance, lessThan(30));
    expect((pairCenter - thirdCenter).distance, greaterThan(35));
    for (var tokenNumber = 1; tokenNumber <= 3; tokenNumber++) {
      final tokenRect = rectForToken(tokenNumber);
      expect(targetCell.contains(tokenRect.topLeft), isTrue);
      expect(targetCell.contains(tokenRect.bottomRight), isTrue);
    }
  });

  testWidgets('locked pair moves as one animated piece', (tester) async {
    final firstToken = TokenState(
      playerIndex: 0,
      tokenIndex: 0,
      isAtStart: false,
      pathIndex: 2,
    );
    final secondToken = TokenState(
      playerIndex: 0,
      tokenIndex: 1,
      isAtStart: false,
      pathIndex: 2,
    );
    firstToken.pairWith(secondToken);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox.square(
          dimension: 500,
          child: GameBoard(
            players: gamePlayers,
            tokens: [firstToken, secondToken],
            movableTokenIds: const {},
            movePaths: {
              firstToken.id: const [BoardCell(1, 0), BoardCell(0, 0)],
              secondToken.id: const [BoardCell(1, 0), BoardCell(0, 0)],
            },
          ),
        ),
      ),
    );

    expect(find.byType(PathAnimatedToken), findsOneWidget);

    final animatedPiece = tester.getSize(find.byType(PathAnimatedToken));
    final tokenSize = tester.getSize(find.byType(GameToken).first);

    expect(animatedPiece.width, greaterThan(tokenSize.width));
    expect(animatedPiece.height, tokenSize.height);
  });
}
