import 'package:isto_king/data/store_assets.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward_definition.dart';

const dailyRewardDefinitions = [
  DailyRewardDefinition(
    day: 1,
    kind: DailyRewardKind.coins,
    coinAmount: 50,
  ),
  DailyRewardDefinition(
    day: 2,
    kind: DailyRewardKind.coins,
    coinAmount: 75,
  ),
  DailyRewardDefinition(
    day: 3,
    kind: DailyRewardKind.coins,
    coinAmount: 100,
  ),
  DailyRewardDefinition(
    day: 4,
    kind: DailyRewardKind.tokenSkin,
    label: 'Token Skin',
    imageAsset: storeMoneyAsset,
  ),
  DailyRewardDefinition(
    day: 5,
    kind: DailyRewardKind.coins,
    coinAmount: 150,
  ),
  DailyRewardDefinition(
    day: 6,
    kind: DailyRewardKind.coins,
    coinAmount: 200,
  ),
  DailyRewardDefinition(
    day: 7,
    kind: DailyRewardKind.festivalChest,
    label: 'Festival Chest',
    imageAsset: storeMoneyAsset,
    coinAmount: 500,
  ),
];
