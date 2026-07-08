import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';

class GameSetupConfig {
  const GameSetupConfig({
    required this.playerCount,
    required this.chipColor,
  });

  final int playerCount;
  final Color chipColor;

  static const defaultConfig = GameSetupConfig(
    playerCount: 4,
    chipColor: RoyalColors.yellow,
  );

  int get humanPlayerIndex => playerIndexForColor(chipColor);

  List<int> get activePlayerIndexes {
    switch (playerCount) {
      case 2:
        final human = humanPlayerIndex;
        if (human == 0 || human == 3) {
          return const [0, 3];
        }
        return const [1, 2];
      case 3:
        final inactive = humanPlayerIndex == 3 ? 2 : 3;
        return [0, 1, 2, 3].where((index) => index != inactive).toList();
      default:
        return const [0, 1, 2, 3];
    }
  }

  Set<int> get activePlayerIndexSet => activePlayerIndexes.toSet();

  int get playersRequiredToFinish => activePlayerIndexes.length - 1;

  static int playerIndexForColor(Color color) {
    if (color == RoyalColors.red) return 0;
    if (color == RoyalColors.green) return 1;
    if (color == RoyalColors.yellow) return 2;
    return 3;
  }
}
