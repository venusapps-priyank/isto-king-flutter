import 'dart:math' as math;

/// Screen seats: 0 = top-left, 1 = top-right, 2 = bottom-left, 3 = bottom-right.
///
/// In vs-computer mode the human is always shown at seat 2 (bottom-left) by
/// rotating the board and remapping player cards to match that view rotation.
class BoardViewLayout {
  const BoardViewLayout._();

  /// Where each player index lands after [quarterTurns] CCW quarter rotations.
  static const List<List<int>> _seatAfterRotationByQuarterTurn = [
    [0, 1, 2, 3],
    [2, 0, 3, 1],
    [3, 2, 1, 0],
    [1, 3, 0, 2],
  ];

  /// CCW quarter turns needed so [humanPlayerIndex] appears at bottom-left.
  static const List<int> _quarterTurnsForHuman = [1, 2, 0, 3];

  static bool shouldRotateForSetup({required bool isVsComputer}) =>
      isVsComputer;

  static int quarterTurnsForHuman(int humanPlayerIndex) =>
      _quarterTurnsForHuman[humanPlayerIndex];

  static double boardRotationRadians(int humanPlayerIndex) =>
      -quarterTurnsForHuman(humanPlayerIndex) * math.pi / 2;

  static int seatForPlayer(int playerIndex, int humanPlayerIndex) {
    final turns = quarterTurnsForHuman(humanPlayerIndex);
    return _seatAfterRotationByQuarterTurn[turns][playerIndex];
  }

  static int playerForSeat(int seat, int humanPlayerIndex) {
    final turns = quarterTurnsForHuman(humanPlayerIndex);
    final mapping = _seatAfterRotationByQuarterTurn[turns];
    for (var playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (mapping[playerIndex] == seat) {
        return playerIndex;
      }
    }
    return seat;
  }

  static bool avatarOnRightForSeat(int seat) => seat == 1 || seat == 3;
}
