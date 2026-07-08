import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/models/game_setup_config.dart';
import 'package:isto_king/features/game/models/player_info.dart';

const baseGamePlayers = [
  PlayerInfo(
    index: 0,
    name: 'Rammohan',
    color: RoyalColors.red,
    avatarAsset: 'assets/avatar/avatar-1.png',
  ),
  PlayerInfo(
    index: 1,
    name: 'Chandrakishore',
    color: RoyalColors.green,
    avatarAsset: 'assets/avatar/avatar-f-1.png',
    avatarOnRight: true,
  ),
  PlayerInfo(
    index: 2,
    name: 'Aaradhya',
    color: RoyalColors.yellow,
    avatarAsset: 'assets/avatar/avatar-2.png',
  ),
  PlayerInfo(
    index: 3,
    name: 'Shaurya',
    color: RoyalColors.blue,
    avatarAsset: 'assets/avatar/avatar-f-2.png',
    avatarOnRight: true,
  ),
];

const gamePlayers = baseGamePlayers;

List<PlayerInfo> buildGamePlayers(GameSetupConfig config) {
  return [
    for (final player in baseGamePlayers)
      player.index == config.humanPlayerIndex
          ? PlayerInfo(
              index: player.index,
              name: 'Player',
              color: config.chipColor,
              avatarAsset: player.avatarAsset,
              avatarOnRight: player.avatarOnRight,
            )
          : player,
  ];
}

PlayerInfo playerInfoForIndex(List<PlayerInfo> players, int index) {
  return players.firstWhere((player) => player.index == index);
}

final topRowPlayers = [gamePlayers[0], gamePlayers[1]];
final bottomRowPlayers = [gamePlayers[2], gamePlayers[3]];
