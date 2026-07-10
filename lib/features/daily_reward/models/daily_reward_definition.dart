import 'package:isto_king/features/daily_reward/models/daily_reward.dart';

class DailyRewardDefinition {
  const DailyRewardDefinition({
    required this.day,
    required this.kind,
    this.coinAmount,
    this.label,
    this.imageAsset,
  });

  final int day;
  final DailyRewardKind kind;
  final int? coinAmount;
  final String? label;
  final String? imageAsset;

  int get rewardCoins {
    if (coinAmount != null) return coinAmount!;
    if (kind == DailyRewardKind.festivalChest) return 1000;
    return 0;
  }
}
