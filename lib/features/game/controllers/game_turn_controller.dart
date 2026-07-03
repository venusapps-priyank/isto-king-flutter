import 'package:isto_king/data/game_constants.dart';

class GameTurnController {
  int currentPlayerIndex = turnOrder.first;
  final List<int?> lastRolls = List<int?>.filled(4, null);

  void handleRollComplete(int playerIndex, int value) {
    lastRolls[playerIndex] = value;
    final turnIndex = turnOrder.indexOf(currentPlayerIndex);
    currentPlayerIndex = turnOrder[(turnIndex + 1) % turnOrder.length];
  }
}
