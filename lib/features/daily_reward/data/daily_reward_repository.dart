import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardProgress {
  const DailyRewardProgress({
    required this.claimedDaysInCycle,
    this.lastClaimDate,
  });

  final int claimedDaysInCycle;
  final DateTime? lastClaimDate;
}

class DailyRewardRepository {
  static const _claimedDaysKey = 'daily_reward_claimed_days';
  static const _lastClaimDateKey = 'daily_reward_last_claim_ymd';

  Future<DailyRewardProgress> load() async {
    final preferences = await SharedPreferences.getInstance();
    final claimedDays = preferences.getInt(_claimedDaysKey) ?? 0;
    final lastClaimDate = _parseDate(preferences.getString(_lastClaimDateKey));

    return DailyRewardProgress(
      claimedDaysInCycle: claimedDays.clamp(0, 7),
      lastClaimDate: lastClaimDate,
    );
  }

  Future<DailyRewardProgress> saveClaim({
    required int claimedDaysInCycle,
    required DateTime claimDate,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_claimedDaysKey, claimedDaysInCycle);
    await preferences.setString(
      _lastClaimDateKey,
      _formatDate(_dateOnly(claimDate)),
    );

    return DailyRewardProgress(
      claimedDaysInCycle: claimedDaysInCycle,
      lastClaimDate: _dateOnly(claimDate),
    );
  }

  Future<void> resetCycle() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_claimedDaysKey, 0);
    await preferences.remove(_lastClaimDateKey);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    return DateTime(year, month, day);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
