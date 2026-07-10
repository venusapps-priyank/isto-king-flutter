import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/game/models/game_setup_config.dart';
import 'package:istochaka/features/game/models/player_info.dart';

const baseGamePlayers = [
  PlayerInfo(
    index: 0,
    name: 'Rammohan',
    color: RoyalColors.red,
    avatarAsset: 'assets/avatar/avatar-m1.png',
  ),
  PlayerInfo(
    index: 1,
    name: 'Chandrakishore',
    color: RoyalColors.green,
    avatarAsset: 'assets/avatar/avatar-f1.png',
    avatarOnRight: true,
  ),
  PlayerInfo(
    index: 2,
    name: 'Aaradhya',
    color: RoyalColors.yellow,
    avatarAsset: 'assets/avatar/avatar-m2.png',
  ),
  PlayerInfo(
    index: 3,
    name: 'Shaurya',
    color: RoyalColors.blue,
    avatarAsset: 'assets/avatar/avatar-f2.png',
    avatarOnRight: true,
  ),
];

const gamePlayers = baseGamePlayers;

List<PlayerInfo> buildGamePlayers(
  GameSetupConfig config, {
  Map<int, String>? computerNamesByIndex,
}) {
  if (config.isPassAndPlay) {
    return [
      for (final player in baseGamePlayers)
        PlayerInfo(
          index: player.index,
          name: 'Player ${player.index + 1}',
          color: player.color,
          avatarAsset: player.avatarAsset,
          avatarOnRight: player.avatarOnRight,
        ),
    ];
  }

  final computerIndexes = config.computerPlayerIndexes.toList()..sort();
  final computerNumberByIndex = {
    for (var i = 0; i < computerIndexes.length; i++)
      computerIndexes[i]: i + 1,
  };

  return [
    for (final player in baseGamePlayers)
      if (player.index == config.humanPlayerIndex)
        PlayerInfo(
          index: player.index,
          name: config.humanPlayerName,
          color: config.chipColor,
          avatarAsset: config.humanPlayerAvatarAsset,
          avatarOnRight: player.avatarOnRight,
        )
      else if (config.isVsComputer &&
          computerNumberByIndex.containsKey(player.index))
        PlayerInfo(
          index: player.index,
          name: computerNamesByIndex?[player.index] ??
              'Computer ${computerNumberByIndex[player.index]}',
          color: player.color,
          avatarAsset: player.avatarAsset,
          avatarOnRight: player.avatarOnRight,
        )
      else
        player,
  ];
}

PlayerInfo playerInfoForIndex(List<PlayerInfo> players, int index) {
  return players.firstWhere((player) => player.index == index);
}

final topRowPlayers = [gamePlayers[0], gamePlayers[1]];
final bottomRowPlayers = [gamePlayers[2], gamePlayers[3]];
