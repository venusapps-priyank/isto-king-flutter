import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/rules/models/game_rules_settings.dart';

class GameSetupConfig {
  const GameSetupConfig({
    required this.playerCount,
    required this.chipColor,
    this.humanPlayerName = 'Player',
    this.humanPlayerAvatarAsset = 'assets/avatar/avatar-m1.png',
    this.rulesSettings = GameRulesSettings.defaults,
    this.isPassAndPlay = false,
  });

  final int playerCount;
  final Color chipColor;
  final String humanPlayerName;
  final String humanPlayerAvatarAsset;
  final GameRulesSettings rulesSettings;
  final bool isPassAndPlay;

  bool get isVsComputer => !isPassAndPlay;

  Set<int> get computerPlayerIndexes => isVsComputer
      ? activePlayerIndexSet.difference({humanPlayerIndex})
      : const {};

  static const defaultConfig = GameSetupConfig(
    playerCount: 4,
    chipColor: RoyalColors.yellow,
  );

  factory GameSetupConfig.fromJson(Map<String, dynamic> json) {
    return GameSetupConfig(
      playerCount: json['playerCount'] as int? ?? 4,
      chipColor: chipColorForPlayerIndex(json['chipPlayerIndex'] as int? ?? 2),
      humanPlayerName: json['humanPlayerName'] as String? ?? 'Player',
      humanPlayerAvatarAsset:
          json['humanPlayerAvatarAsset'] as String? ??
          'assets/avatar/avatar-m1.png',
      rulesSettings: GameRulesSettings.fromJson(
        (json['rulesSettings'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      isPassAndPlay: json['isPassAndPlay'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerCount': playerCount,
      'chipPlayerIndex': humanPlayerIndex,
      'humanPlayerName': humanPlayerName,
      'humanPlayerAvatarAsset': humanPlayerAvatarAsset,
      'rulesSettings': rulesSettings.toJson(),
      'isPassAndPlay': isPassAndPlay,
    };
  }

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

  static Color chipColorForPlayerIndex(int playerIndex) {
    return switch (playerIndex) {
      0 => RoyalColors.red,
      1 => RoyalColors.green,
      2 => RoyalColors.yellow,
      _ => RoyalColors.blue,
    };
  }
}
