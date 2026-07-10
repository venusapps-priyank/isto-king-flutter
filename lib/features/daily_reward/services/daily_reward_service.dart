import 'package:isto_king/data/daily_reward_catalog.dart';
import 'package:isto_king/features/daily_reward/data/daily_reward_repository.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward.dart';
import 'package:isto_king/features/daily_reward/models/daily_reward_definition.dart';
import 'package:isto_king/features/wallet/coin_wallet.dart';

class DailyRewardService {
  DailyRewardService({
    DailyRewardRepository? repository,
    CoinWallet? coinWallet,
  })  : _repository = repository ?? DailyRewardRepository(),
        _coinWallet = coinWallet ?? CoinWallet.instance;

  final DailyRewardRepository _repository;
  final CoinWallet _coinWallet;

  Future<DailyRewardState> loadState({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final progress = await _loadNormalizedProgress(currentTime);
    return _buildState(progress, now: currentTime);
  }

  Future<DailyRewardState> claim({DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final progress = await _loadNormalizedProgress(currentTime);
    final snapshot = _resolveProgress(progress, now: currentTime);
    if (!snapshot.canClaimToday) {
      return _buildState(progress, now: currentTime);
    }

    final rewardDay = progress.claimedDaysInCycle + 1;
    final definition = dailyRewardDefinitions[rewardDay - 1];
    final rewardCoins = definition.rewardCoins;

    if (rewardCoins > 0) {
      await _coinWallet.addCoins(rewardCoins);
    }

    final savedProgress = await _repository.saveClaim(
      claimedDaysInCycle: rewardDay,
      claimDate: currentTime,
    );

    return _buildState(savedProgress, now: currentTime);
  }

  Future<DailyRewardProgress> _loadNormalizedProgress(DateTime now) async {
    final progress = await _repository.load();
    final lastClaimDate = progress.lastClaimDate;
    if (lastClaimDate == null) return progress;

    final daysSinceClaim =
        _dateOnly(now).difference(_dateOnly(lastClaimDate)).inDays;
    if (daysSinceClaim == 0) return progress;
    if (daysSinceClaim == 1 && progress.claimedDaysInCycle < 7) {
      return progress;
    }

    await _repository.resetCycle();
    return const DailyRewardProgress(claimedDaysInCycle: 0);
  }

  DailyRewardState _buildState(
    DailyRewardProgress progress, {
    required DateTime now,
  }) {
    final snapshot = _resolveProgress(progress, now: now);

    final days = [
      for (var i = 0; i < dailyRewardDefinitions.length; i++)
        _mapDefinitionToDay(
          dailyRewardDefinitions[i],
          status: _statusForDay(
            dayNumber: i + 1,
            claimedDays: snapshot.progress.claimedDaysInCycle,
            canClaimToday: snapshot.canClaimToday,
          ),
        ),
    ];

    return DailyRewardState(
      days: days,
      currentStreak: snapshot.progress.claimedDaysInCycle,
      nextRewardIn: snapshot.nextRewardIn,
      canClaimToday: snapshot.canClaimToday,
    );
  }

  DailyRewardDay _mapDefinitionToDay(
    DailyRewardDefinition definition, {
    required DailyRewardStatus status,
  }) {
    return DailyRewardDay(
      day: definition.day,
      kind: definition.kind,
      status: status,
      coinAmount: definition.coinAmount,
      label: definition.label,
      imageAsset: definition.imageAsset,
    );
  }

  DailyRewardStatus _statusForDay({
    required int dayNumber,
    required int claimedDays,
    required bool canClaimToday,
  }) {
    if (dayNumber <= claimedDays) return DailyRewardStatus.claimed;
    if (dayNumber == claimedDays + 1 && canClaimToday) {
      return DailyRewardStatus.available;
    }
    return DailyRewardStatus.locked;
  }

  _ResolvedProgress _resolveProgress(
    DailyRewardProgress progress, {
    required DateTime now,
  }) {
    final lastClaimDate = progress.lastClaimDate;

    if (lastClaimDate == null) {
      return const _ResolvedProgress(
        progress: DailyRewardProgress(claimedDaysInCycle: 0),
        canClaimToday: true,
        nextRewardIn: Duration.zero,
      );
    }

    final daysSinceClaim =
        _dateOnly(now).difference(_dateOnly(lastClaimDate)).inDays;

    if (daysSinceClaim == 0) {
      return _ResolvedProgress(
        progress: progress,
        canClaimToday: false,
        nextRewardIn: _timeUntilNextDay(now),
      );
    }

    return _ResolvedProgress(
      progress: progress,
      canClaimToday: true,
      nextRewardIn: Duration.zero,
    );
  }

  Duration _timeUntilNextDay(DateTime now) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remaining = tomorrow.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _ResolvedProgress {
  const _ResolvedProgress({
    required this.progress,
    required this.canClaimToday,
    required this.nextRewardIn,
  });

  final DailyRewardProgress progress;
  final bool canClaimToday;
  final Duration nextRewardIn;
}
