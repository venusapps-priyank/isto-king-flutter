import 'package:isto_king/data/store_assets.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward.dart';

const dailyRewardDays = [
  DailyRewardDay(
    day: 1,
    kind: DailyRewardKind.coins,
    status: DailyRewardStatus.claimed,
    coinAmount: 50,
  ),
  DailyRewardDay(
    day: 2,
    kind: DailyRewardKind.coins,
    status: DailyRewardStatus.available,
    coinAmount: 75,
  ),
  DailyRewardDay(
    day: 3,
    kind: DailyRewardKind.coins,
    status: DailyRewardStatus.locked,
    coinAmount: 100,
  ),
  DailyRewardDay(
    day: 4,
    kind: DailyRewardKind.tokenSkin,
    status: DailyRewardStatus.locked,
    label: 'Token Skin',
    imageAsset: storeMoneyAsset,
  ),
  DailyRewardDay(
    day: 5,
    kind: DailyRewardKind.coins,
    status: DailyRewardStatus.locked,
    coinAmount: 150,
  ),
  DailyRewardDay(
    day: 6,
    kind: DailyRewardKind.coins,
    status: DailyRewardStatus.locked,
    coinAmount: 200,
  ),
  DailyRewardDay(
    day: 7,
    kind: DailyRewardKind.festivalChest,
    status: DailyRewardStatus.locked,
    label: 'Festival Chest',
    imageAsset: storeMoneyAsset,
  ),
];

DailyRewardState buildDailyRewardState() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);

  return DailyRewardState(
    days: dailyRewardDays,
    currentStreak: 1,
    nextRewardIn: tomorrow.difference(now),
    canClaimToday: true,
  );
}
