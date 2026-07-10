enum DailyRewardKind { coins, tokenSkin, festivalChest }

enum DailyRewardStatus { claimed, available, locked }

class DailyRewardDay {
  const DailyRewardDay({
    required this.day,
    required this.kind,
    required this.status,
    this.coinAmount,
    this.label,
    this.imageAsset,
  });

  final int day;
  final DailyRewardKind kind;
  final DailyRewardStatus status;
  final int? coinAmount;
  final String? label;
  final String? imageAsset;
}

class DailyRewardState {
  const DailyRewardState({
    required this.days,
    required this.currentStreak,
    required this.nextRewardIn,
    this.canClaimToday = false,
  });

  final List<DailyRewardDay> days;
  final int currentStreak;
  final Duration nextRewardIn;
  final bool canClaimToday;
}
