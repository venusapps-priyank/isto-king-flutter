import 'package:isto_king/features/game/models/board_cell.dart';

class IstoBoardPaths {
  const IstoBoardPaths._();

  static const int gridCount = 5;
  static const int outerPathLength = 15;
  static const BoardCell centerCell = BoardCell(2, 2);

  static const List<BoardCell> homeCells = [
    BoardCell(2, 0), // Red
    BoardCell(4, 2), // Green
    BoardCell(0, 2), // Yellow
    BoardCell(2, 4), // Blue
  ];

  static final Set<BoardCell> safeCells = {
    const BoardCell(2, 0),
    const BoardCell(4, 2),
    const BoardCell(0, 2),
    const BoardCell(2, 4),
  };

  static const List<BoardCell> _outerLoop = [
    BoardCell(2, 0),
    BoardCell(1, 0),
    BoardCell(0, 0),
    BoardCell(0, 1),
    BoardCell(0, 2),
    BoardCell(0, 3),
    BoardCell(0, 4),
    BoardCell(1, 4),
    BoardCell(2, 4),
    BoardCell(3, 4),
    BoardCell(4, 4),
    BoardCell(4, 3),
    BoardCell(4, 2),
    BoardCell(4, 1),
    BoardCell(4, 0),
    BoardCell(3, 0),
  ];

  static const List<int> _homeLoopIndexes = [0, 12, 4, 8];

  static const List<List<BoardCell>> _innerPaths = [
    [
      BoardCell(3, 1),
      BoardCell(3, 2),
      BoardCell(3, 3),
      BoardCell(2, 3),
      BoardCell(1, 3),
      BoardCell(1, 2),
      BoardCell(1, 1),
      BoardCell(2, 1),
      centerCell,
    ],
    [
      BoardCell(3, 3),
      BoardCell(2, 3),
      BoardCell(1, 3),
      BoardCell(1, 2),
      BoardCell(1, 1),
      BoardCell(2, 1),
      BoardCell(3, 1),
      BoardCell(3, 2),
      centerCell,
    ],
    [
      BoardCell(1, 1),
      BoardCell(2, 1),
      BoardCell(3, 1),
      BoardCell(3, 2),
      BoardCell(3, 3),
      BoardCell(2, 3),
      BoardCell(1, 3),
      BoardCell(1, 2),
      centerCell,
    ],
    [
      BoardCell(1, 3),
      BoardCell(1, 2),
      BoardCell(1, 1),
      BoardCell(2, 1),
      BoardCell(3, 1),
      BoardCell(3, 2),
      BoardCell(3, 3),
      BoardCell(2, 3),
      centerCell,
    ],
  ];

  static final List<List<BoardCell>> playerPaths = List.unmodifiable(
    List<List<BoardCell>>.generate(4, (playerIndex) {
      final homeIndex = _homeLoopIndexes[playerIndex];
      final outerPath = <BoardCell>[
        for (var offset = 1; offset < _outerLoop.length; offset++)
          _outerLoop[(homeIndex + offset) % _outerLoop.length],
      ];
      return List<BoardCell>.unmodifiable([
        ...outerPath,
        ..._innerPaths[playerIndex],
      ]);
    }),
  );

  static BoardCell homeCellForPlayer(int playerIndex) {
    return homeCells[playerIndex];
  }

  static List<BoardCell> pathForPlayer(int playerIndex) {
    return playerPaths[playerIndex];
  }

  static bool isSafeCell(BoardCell cell) {
    return safeCells.contains(cell);
  }
}
