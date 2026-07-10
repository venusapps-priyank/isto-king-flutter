import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/data/store_assets.dart';
import 'package:istochaka/features/daily_reward/models/daily_reward.dart';
class DailyRewardDayTile extends StatelessWidget {
  const DailyRewardDayTile({
    required this.reward,
    this.scale = 1,
    super.key,
  });

  final DailyRewardDay reward;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isClaimed = reward.status == DailyRewardStatus.claimed;
    final isAvailable = reward.status == DailyRewardStatus.available;
    final isLocked = reward.status == DailyRewardStatus.locked;
    final isGrandPrize = reward.kind == DailyRewardKind.festivalChest;
    final padding = 3.5 * scale;
    final footerHeight = 15.0 * scale;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * scale),
        gradient: isGrandPrize
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9E1B1B), Color(0xFF5A0505)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8EA), Color(0xFFF6E8C8)],
              ),
        border: Border.all(
          color: isAvailable || isClaimed
              ? RoyalColors.gold
              : RoyalColors.brown.withValues(alpha: 0.35),
          width: isAvailable ? 2 : 1.2,
        ),
        boxShadow: isAvailable
            ? [
                BoxShadow(
                  color: RoyalColors.gold.withValues(alpha: 0.45),
                  blurRadius: 8 * scale,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            _DayBanner(day: reward.day, scale: scale),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _RewardVisual(reward: reward, scale: scale),
                ),
              ),
            ),
            SizedBox(
              height: footerHeight,
              width: double.infinity,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _FooterStatus(
                    isClaimed: isClaimed,
                    isAvailable: isAvailable,
                    isLocked: isLocked,
                    isGrandPrize: isGrandPrize,
                    scale: scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStatus extends StatelessWidget {
  const _FooterStatus({
    required this.isClaimed,
    required this.isAvailable,
    required this.isLocked,
    required this.isGrandPrize,
    required this.scale,
  });

  final bool isClaimed;
  final bool isAvailable;
  final bool isLocked;
  final bool isGrandPrize;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isClaimed) {
      return _StatusChip(
        label: 'CLAIMED',
        color: RoyalColors.green,
        icon: Icons.check_rounded,
        scale: scale,
      );
    }
    if (isAvailable) {
      return _StatusChip(
        label: 'PENDING',
        color: RoyalColors.yellow,
        icon: Icons.schedule_rounded,
        textColor: RoyalColors.darkBrown,
        scale: scale,
      );
    }
    if (isLocked) {
      return Icon(
        Icons.lock_rounded,
        size: 12 * scale,
        color: isGrandPrize
            ? const Color(0xFFFFE39D)
            : RoyalColors.brown.withValues(alpha: 0.45),
      );
    }
    return const SizedBox.shrink();
  }
}

class _DayBanner extends StatelessWidget {
  const _DayBanner({required this.day, required this.scale});

  final int day;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.5 * scale),
      decoration: BoxDecoration(
        color: RoyalColors.outerRed,
        borderRadius: BorderRadius.circular(5 * scale),
        border: Border.all(color: RoyalColors.gold, width: 0.8),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'DAY $day',
          style: TextStyle(
            color: const Color(0xFFFFE39D),
            fontWeight: FontWeight.w900,
            fontSize: 9 * scale,
            height: 1,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

class _RewardVisual extends StatelessWidget {
  const _RewardVisual({required this.reward, required this.scale});

  final DailyRewardDay reward;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final isGrandPrize = reward.kind == DailyRewardKind.festivalChest;
    final imageHeight = isGrandPrize ? 38 * scale : 28 * scale;
    final imageAsset = reward.imageAsset ?? storeMoneyAsset;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imageAsset,
          height: imageHeight,
          fit: BoxFit.contain,
        ),
        if (reward.coinAmount != null) ...[
          SizedBox(height: 1 * scale),
          Text(
            '${reward.coinAmount}',
            style: TextStyle(
              color: isGrandPrize
                  ? const Color(0xFFFFE39D)
                  : RoyalColors.darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: 12 * scale,
              height: 1,
            ),
          ),
        ] else if (reward.label != null) ...[
          SizedBox(height: 1 * scale),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 72 * scale),
            child: Text(
              reward.label!.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isGrandPrize
                    ? const Color(0xFFFFE39D)
                    : RoyalColors.darkBrown,
                fontWeight: FontWeight.w900,
                fontSize: 7.5 * scale,
                height: 1.05,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.scale,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final IconData icon;
  final double scale;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4 * scale,
        vertical: 1 * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 9 * scale),
          SizedBox(width: 2 * scale),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 7.5 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
