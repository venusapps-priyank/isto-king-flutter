import 'package:flutter/material.dart';
import 'package:isto_king/core/theme/royal_colors.dart';
import 'package:isto_king/features/game/widgets/coin_icon.dart';

class CoinBalancePill extends StatelessWidget {
  const CoinBalancePill({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: 24),
          SizedBox(width: 6),
          Text(
            '120',
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          SizedBox(width: 7),
          CircleAvatar(
            radius: 13,
            backgroundColor: Color(0xFF3AAA45),
            child: Icon(Icons.add, color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }
}
