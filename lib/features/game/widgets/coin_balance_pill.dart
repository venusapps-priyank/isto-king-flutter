import 'package:flutter/material.dart';
import 'package:istochaka/core/theme/royal_colors.dart';
import 'package:istochaka/features/daily_reward/widgets/daily_reward_dialog.dart';
import 'package:istochaka/features/game/widgets/coin_icon.dart';
import 'package:istochaka/features/wallet/coin_wallet.dart';

class CoinBalancePill extends StatelessWidget {
  const CoinBalancePill({this.onAddTap, super.key});

  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CoinWallet.instance.balance,
      builder: (context, balance, _) {
        return Container(
          height: 34,
          padding: const EdgeInsets.fromLTRB(6, 3, 3, 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE1B2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: RoyalColors.brown.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CoinIcon(size: 24),
              const SizedBox(width: 6),
              Text(
                '$balance',
                style: const TextStyle(
                  color: RoyalColors.darkBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 7),
              GestureDetector(
                onTap: onAddTap ?? () => DailyRewardDialog.show(context),
                child: const CircleAvatar(
                  radius: 13,
                  backgroundColor: Color(0xFF3AAA45),
                  child: Icon(Icons.add, color: Colors.white, size: 19),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
